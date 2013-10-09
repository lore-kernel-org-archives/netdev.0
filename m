From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH v2 tip/core/rcu 0/13] Sparse-related updates for 3.13
Date: Wed, 9 Oct 2013 15:18:05 -0700
Message-ID: <20131009221805.GA11709@jtriplet-mobl1>
References: <20131009212920.GA15413@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org,
	laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	niv@us.ibm.com, tglx@linutronix.de, peterz@infradead.org,
	rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com,
	darren@dvhart.com, fweisbec@gmail.com, sbw@mit.edu,
	fengguang.wu@intel.com, stephen@networkplumber.org,
	davem@davemloft.net, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, tgraf@suug.ch, gaofeng@cn.fujitsu.com,
	linux-decnet-user@lists.sourceforge.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linville@tuxdriver.com, johannes@sipsolutions.net
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131009212920.GA15413@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 09, 2013 at 02:29:20PM -0700, Paul E. McKenney wrote:
> Hello!
> 
> This series features updates to allow sparse to do a better job of
> statically analyzing RCU usage:
> 
> 1.	Apply ACCESS_ONCE() to rcu_assign_pointer()'s target to prevent
> 	comiler mischief.  Also require that the source pointer be from
> 	the kernel address space.  Sometimes it can be from the RCU address
> 	space, which necessitates the remaining patches in this series.
> 	Which, it must be admitted, apply to a very small fraction of
> 	the rcu_assign_pointer() invocations in the kernel.  This commit
> 	courtesy of Josh Triplett.
> 
> 2-13.	Apply rcu_access_pointer() to avoid a number of false positives.

I would suggest moving patch 1 to the end of the series, to avoid
introducing and subsequently fixing warnings.

- Josh Triplett
