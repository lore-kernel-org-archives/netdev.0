From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH 31/45] alpha/smp: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Mon, 24 Jun 2013 00:26:38 +0530
Message-ID: <51C744E6.1040905@linux.vnet.ibm.com>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com> <20130623134516.19094.57189.stgit@srivatsabhat.in.ibm.com> <CAEdQ38HLzNoRABCUR7tEoBLJWn86xSd2VfSHxs0MPj5r5GvTXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, rostedt@goodmis.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	sbw@mit.edu, fweisbec@gmail.com, zhong@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Richard Henderson <rth@twiddle.net>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	linux-alpha@vger.kernel.org
To: Matt Turner <mattst88@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CAEdQ38HLzNoRABCUR7tEoBLJWn86xSd2VfSHxs0MPj5r5GvTXQ@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2013 11:20 PM, Matt Turner wrote:
> On Sun, Jun 23, 2013 at 6:45 AM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> Once stop_machine() is gone from the CPU offline path, we won't be able
>> to depend on disabling preemption to prevent CPUs from going offline
>> from under us.
>>
>> Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
>> offline, while invoking from atomic context.
>>
>> Also, remove the non-ASCII character present in this file!
> 
> It's not non-ASCII. It's a page break.
> 

Oh, ok..

Regards,
Srivatsa S. Bhat
