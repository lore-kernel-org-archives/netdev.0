From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Thu, 01 Jul 2010 16:53:38 +0200
Message-ID: <4C2CABF2.2020801@kernel.org>
References: <1277983179.1917.10.camel@laptop> <1277984603.1917.15.camel@laptop> <20100701115507.GA31333@redhat.com> <20100701122340.GB31333@redhat.com> <1277987657.1917.32.camel@laptop> <1277988395.1917.47.camel@laptop> <20100701130816.GB32223@redhat.com> <1277991024.1917.108.camel@laptop> <20100701133956.GD32223@redhat.com> <4C2CA5C5.4040402@kernel.org> <20100701144624.GA11171@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100701144624.GA11171@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/01/2010 04:46 PM, Oleg Nesterov wrote:
>> It might be a good idea to make the function take extra clone flags
>> but anyways once created cloned task can be treated the same way as
>> other kthreads, so nothing else needs to be changed.
> 
> This makes kthread_stop() work. Otherwise the new thread is just
> the CLONE_VM child of the caller, and the caller is the user-mode
> task doing ioctl() ?

Hmmm, indeed.  It makes the attribute inheritance work but circumvents
the whole reason there is kthreadd.

Thanks.

-- 
tejun
