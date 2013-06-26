From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Wed, 26 Jun 2013 14:34:58 -0700
Message-ID: <20130626213458.GC4536@htj.dyndns.org>
References: <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com>
 <20130625220026.GG3828@linux.vnet.ibm.com>
 <51CAF624.6060004@linux.vnet.ibm.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com>
 <20130626143424.GN3828@linux.vnet.ibm.com>
 <1372258271.18733.256.camel@gandalf.local.home>
 <20130626152148.GA4405@mtj.dyndns.org>
 <1372260823.18733.263.camel@gandalf.local.home>
 <20130626172948.GD4405@mtj.dyndns.org>
 <51CB32E0.3040106@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>, peterz@infradead.org,
	fweisbec@gmail.com, oleg@redhat.com, walken@google.com,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	vincent.guittot@linaro.org, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, namhyung@kernel.org, tglx@linutronix.de,
	laijs@cn.fujitsu.com, zhong@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, sbw@mit.edu,
	David Laight <David.Laight@ACULAB.COM>,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51CB32E0.3040106@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

On Wed, Jun 26, 2013 at 11:58:48PM +0530, Srivatsa S. Bhat wrote:
> Yes, we were discussing hot-unplug latency for use-cases such as
> suspend/resume. We didn't want to make those operations slower in the
> process of removing stop_machine() from hotplug.

Can you please explain why tho?  How much would it help in terms of
power-saving?  Or are there other issues in taking longer to shut down
cpus?

Thanks.

-- 
tejun
