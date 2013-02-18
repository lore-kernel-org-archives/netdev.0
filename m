From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 00/45] CPU hotplug: stop_machine()-free CPU hotplug
Date: Mon, 18 Feb 2013 10:30:22 -0500
Message-ID: <1361201422.23152.154.camel@gandalf.local.home>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
	 <510FBC01.2030405@linux.vnet.ibm.com> <87haloiwv0.fsf@rustcorp.com.au>
	 <51134596.4080106@linux.vnet.ibm.com>
	 <20130208154113.GV17833@n2100.arm.linux.org.uk>
	 <51152B81.2050501@linux.vnet.ibm.com> <51153F72.1060005@linux.vnet.ibm.com>
	 <CAKfTPtCe+cD7LLkb+D6pqG1SwG2V08ws=4XO3ttHEHV2qgmqPg@mail.gmail.com>
	 <5118E2CD.90401@linux.vnet.ibm.com>
	 <20130211190852.GA5695@linux.vnet.ibm.com>
	 <5119BDFD.1000909@linux.vnet.ibm.com>
	 <CAKfTPtAo2hQTfBKTVUuLKgsGJ2ZLD0UTR3fH9UFuJwyFt4n__w@mail.gmail.com>
	 <511E8F3C.2010406@linux.vnet.ibm.com>
	 <CAKfTPtD=2jn1AVjuhVP1ot7_8x9-W4==hNGZET5N9tRE7gtyMw@mail.gmail.com>
	 <512203B3.7090002@linux.vnet.ibm.com> <512207A6.4000402@linux.vnet.ibm.com>
	 <CAKfTPtA1aTseD6Gntkf_zbCEbfZzt3P2-P1un6iF5_1TdVLjRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	paulmck@linux.vnet.ibm.com,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	walken@google.com, mingo@kernel.org, linux-arch@vger.kernel.org,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>, rjw@sisk.pl,
	namhyung@kernel.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Vincent Guittot <vincent.guittot@linaro.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CAKfTPtA1aTseD6Gntkf_zbCEbfZzt3P2-P1un6iF5_1TdVLjRQ@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-02-18 at 11:58 +0100, Vincent Guittot wrote:

> My tests have been done without cpuidle because i have some issues
> with function tracer and cpuidle
> 
> But the cpu hotplug and cpuidle work well when I run the tests without
> enabling the function tracer
> 

I know suspend and resume has issues with function tracing (because it
makes things like calling smp_processor_id() crash the system), but I'm
unaware of issues with hotplug itself. Could be some of the same issues.

Can you give me more details, I'll try to investigate it.

Thanks,

-- Steve
