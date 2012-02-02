From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC tip/core/rcu 10/41] ipv4: Convert call_rcu() to
 kfree_rcu()
Date: Thu, 2 Feb 2012 07:56:12 -0800
Message-ID: <20120202155612.GG2518@linux.vnet.ibm.com>
References: <20120201194131.GA10028@linux.vnet.ibm.com>
 <1328125319-5205-1-git-send-email-paulmck@linux.vnet.ibm.com>
 <1328125319-5205-10-git-send-email-paulmck@linux.vnet.ibm.com>
 <20120202002403.GB29058@leaf>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	dipankar@in.ibm.com, akpm@linux-foundation.org,
	mathieu.desnoyers@polymtl.ca, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, Valdis.Kletnieks@vt.edu,
	dhowells@redhat.com, eric.dumazet@gmail.com, darren@dvhart.com,
	fweisbec@gmail.com, patches@linaro.org,
	"Paul E. McKenney" <paul.mckenney@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120202002403.GB29058@leaf>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 01, 2012 at 04:24:03PM -0800, Josh Triplett wrote:
> On Wed, Feb 01, 2012 at 11:41:28AM -0800, Paul E. McKenney wrote:
> > From: "Paul E. McKenney" <paul.mckenney@linaro.org>
> > 
> > The call_rcu() in do_ip_setsockopt() invokes opt_kfree_rcu(), which just
> > calls kfree().  So convert the call_rcu() to kfree_rcu(), which allows
> > opt_kfree_rcu() to be eliminated.
> 
> This and patch 9/41 have exactly the same subject line.  Consider
> adding the name of the function you replaced to each one, to
> disambiguate them.

Good point, will also add function names to the other three kfree_rcu()
patches.

							Thanx, Paul
