From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v6 00/46] CPU hotplug: stop_machine()-free CPU hotplug
Date: Fri, 22 Feb 2013 11:01:46 +1030
Message-ID: <87mwuxfatp.fsf@rustcorp.com.au>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, mingo@kernel.org,
	akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> writes:
> Hi,
>
> This patchset removes CPU hotplug's dependence on stop_machine() from the CPU
> offline path and provides an alternative (set of APIs) to preempt_disable() to
> prevent CPUs from going offline, which can be invoked from atomic context.
> The motivation behind the removal of stop_machine() is to avoid its ill-effects
> and thus improve the design of CPU hotplug. (More description regarding this
> is available in the patches).

If you're doing a v7, please put your benchmark results somewhere!

The obvious place is in the 44/46.

Thanks,
Rusty.
