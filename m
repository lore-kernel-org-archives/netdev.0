From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Wed, 26 Jun 2013 10:51:11 -0400
Message-ID: <1372258271.18733.256.camel@gandalf.local.home>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
	 <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com>
	 <20130625220026.GG3828@linux.vnet.ibm.com>
	 <51CAF624.6060004@linux.vnet.ibm.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com>
	 <20130626143424.GN3828@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	peterz@infradead.org, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, walken@google.com, mingo@kernel.org,
	linux-arch@vger.kernel.org, vincent.guittot@linaro.org,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, namhyung@kernel.org, tglx@linutronix.de,
	laijs@cn.fujitsu.com, zhong@linux.vnet.ibm.com,
	netdev@vger.kernel.org, oleg@redhat.com, sbw@mit.edu,
	tj@kernel.org, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130626143424.GN3828@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-26 at 07:34 -0700, Paul E. McKenney wrote:
> On Wed, Jun 26, 2013 at 03:29:40PM +0100, David Laight wrote:
> > > Once stop_machine() is gone from the CPU offline path, we won't be able
> > > to depend on disabling preemption to prevent CPUs from going offline
> > > from under us.
> > 
> > Could you use an rcu-like sequence so that disabling pre-emption
> > would be enough?
> > 
> > Something like rebuilding the cpu list, then forcing yourself
> > to run on all the cpu.
> > 
> > That would be far less intrusive.
> 
> It would also increase the latency of CPU-hotunplug operations.
> 

Is that a big deal?

-- Steve
