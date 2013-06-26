From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Wed, 26 Jun 2013 08:21:48 -0700
Message-ID: <20130626152148.GA4405@mtj.dyndns.org>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
 <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com>
 <20130625220026.GG3828@linux.vnet.ibm.com>
 <51CAF624.6060004@linux.vnet.ibm.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com>
 <20130626143424.GN3828@linux.vnet.ibm.com>
 <1372258271.18733.256.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, David Laight <David.Laight@ACULAB.COM>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	peterz@infradead.org, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, walken@google.com, mingo@kernel.org,
	linux-arch@vger.kernel.org, vincent.guittot@linaro.org,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, namhyung@kernel.org, tglx@linutronix.de,
	laijs@cn.fujitsu.com, zhong@linux.vnet.ibm.com,
	netdev@vger.kernel.org, oleg@redhat.com, sbw@mit.edu,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1372258271.18733.256.camel@gandalf.local.home>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 26, 2013 at 10:51:11AM -0400, Steven Rostedt wrote:
> > It would also increase the latency of CPU-hotunplug operations.
> 
> Is that a big deal?

I thought that was the whole deal with this patchset - making cpu
hotunplugs lighter and faster mostly for powersaving.  That said, just
removing stop_machine call would be a pretty good deal and I don't
know how meaningful reducing CPU hotunplug latency is.  Srivatsa?

Thanks.

-- 
tejun
