From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH v3 tip/core/rcu 0/14] Sparse-related updates for 3.13
Date: Fri, 11 Oct 2013 23:53:27 -0700
Message-ID: <20131012065326.GG15339@leaf>
References: <20131011231659.GA28062@linux.vnet.ibm.com>
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
In-Reply-To: <20131011231659.GA28062@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 11, 2013 at 04:16:59PM -0700, Paul E. McKenney wrote:
> Changes from v2:
> 
> o	Switch from rcu_assign_pointer() to ACCESS_ONCE() given that
> 	the pointers are all --rcu and already visible to readers,
> 	as suggested by Eric Dumazet and Josh Triplett.

Hang on a moment.  Do *none* of these cases need write memory barriers?

- Josh Triplet
