From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 tip/core/rcu 05/13] decnet: Apply rcu_access_pointer()
 to avoid sparse false positive
Date: Wed, 9 Oct 2013 16:57:08 -0700
Message-ID: <20131009235708.GI5790@linux.vnet.ibm.com>
References: <20131009212920.GA15413@linux.vnet.ibm.com>
 <1381354186-16285-1-git-send-email-paulmck@linux.vnet.ibm.com>
 <1381354186-16285-5-git-send-email-paulmck@linux.vnet.ibm.com>
 <20131009222842.GD11709@jtriplet-mobl1>
 <20131009224604.GF5790@linux.vnet.ibm.com>
 <20131009225716.GI11709@jtriplet-mobl1>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org,
	laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	niv@us.ibm.com, tglx@linutronix.de, peterz@infradead.org,
	rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com,
	darren@dvhart.com, fweisbec@gmail.com, sbw@mit.edu,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Gao feng <gaofeng@cn.fujitsu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131009225716.GI11709@jtriplet-mobl1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 09, 2013 at 03:57:16PM -0700, Josh Triplett wrote:
> On Wed, Oct 09, 2013 at 03:46:04PM -0700, Paul E. McKenney wrote:
> > On Wed, Oct 09, 2013 at 03:28:42PM -0700, Josh Triplett wrote:
> > > On Wed, Oct 09, 2013 at 02:29:38PM -0700, Paul E. McKenney wrote:
> > > > From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> > > > 
> > > > The sparse checking for rcu_assign_pointer() was recently upgraded
> > > > to reject non-__kernel address spaces.  This also rejects __rcu,
> > > > which is almost always the right thing to do.  However, the use in
> > > > dn_insert_route() is legitimate: It is assigning a pointer to an element
> > > 
> > > Nit: "uses ... are", not "use ... is". :)
> > 
> > Don't I already have "use ... is"?
> 
> I was suggesting that it needed to change from "use ... is" to "uses ...
> are", not the other way around.

I guess there really are two uses rather than just one.  ;-)

							Thanx, Paul
