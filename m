From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Soft Lockups on 2.6.28-rc8 under netperf bulk receive workload
Date: Wed, 17 Dec 2008 11:44:09 -0800
Message-ID: <49495689.9090205@hp.com>
References: <4948566E.1050309@hp.com> <494934C5.5000003@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	linux-ia64@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <494934C5.5000003@chelsio.com>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> Can you please reconfigure your kernel with the following kernel hacking
> options enabled, and run your tests again?
> 
> Kernel hacking
> 	Kernel debugging
> 		Detect soft lockups
> 	RT mutex debugging
> 	Spinlock and rw-lock debugging: basic checks
> 	Mutex debugging: basic checks

Got the above

> 	Lock debugging: detect incorrect freeing of live locks
> 	Lock debugging: prove locking correctness

I don't see those two above in a make menuconfig

> 	Spinlock debugging: sleep-inside-spinlock checking
> 	Compile the kernel with debug info

Got those above.

> 	Compile the kernel with frame pointers

That doesn't appear in make menuconfig in kernel hacking either.

I built a kernel with those I could find enabled, and I think it invoked 
the spirit of Heisenberg - no more soft lockups appearing on the 
console.  I think it has also _significantly_ dropped the throughput.

I've since learned how to tell caliper one doesn't care about the 
per-process stuff and just lump it all together.  The cycles and cgprof 
profiles for the debug run can be found under the same URL as before:

ftp://ftp.netperf.org/lockup

with what I hope are obvious names.

rick jones
