From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC tip/core/rcu 10/41] ipv4: Convert call_rcu() to
 kfree_rcu()
Date: Wed, 01 Feb 2012 14:50:29 -0500 (EST)
Message-ID: <20120201.145029.1873008611296502262.davem@davemloft.net>
References: <20120201194131.GA10028@linux.vnet.ibm.com>
	<1328125319-5205-1-git-send-email-paulmck@linux.vnet.ibm.com>
	<1328125319-5205-10-git-send-email-paulmck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	dipankar@in.ibm.com, akpm@linux-foundation.org,
	mathieu.desnoyers@polymtl.ca, josh@joshtriplett.org,
	niv@us.ibm.com, tglx@linutronix.de, peterz@infradead.org,
	rostedt@goodmis.org, Valdis.Kletnieks@vt.edu, dhowells@redhat.com,
	eric.dumazet@gmail.com, darren@dvhart.com, fweisbec@gmail.com,
	patches@linaro.org, paul.mckenney@linaro.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328125319-5205-10-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed,  1 Feb 2012 11:41:28 -0800

> From: "Paul E. McKenney" <paul.mckenney@linaro.org>
> 
> The call_rcu() in do_ip_setsockopt() invokes opt_kfree_rcu(), which just
> calls kfree().  So convert the call_rcu() to kfree_rcu(), which allows
> opt_kfree_rcu() to be eliminated.
> 
> Signed-off-by: Paul E. McKenney <paul.mckenney@linaro.org>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
