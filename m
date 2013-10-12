From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 tip/core/rcu 0/14] Sparse-related updates
	for 3.13
Date: Sat, 12 Oct 2013 10:13:45 -0700
Message-ID: <20131012171345.GB5790@linux.vnet.ibm.com>
References: <20131011231659.GA28062@linux.vnet.ibm.com>
	<20131012065326.GG15339@leaf>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peterz@infradead.org, fweisbec@gmail.com, dhowells@redhat.com,
	edumazet@google.com, gaofeng@cn.fujitsu.com, mingo@kernel.org,
	bridge@lists.linux-foundation.org, jmorris@namei.org,
	dipankar@in.ibm.com, darren@dvhart.com, rostedt@goodmis.org,
	niv@us.ibm.com, mathieu.desnoyers@efficios.com,
	kuznet@ms2.inr.ac.ru, tglx@linutronix.de,
	johannes@sipsolutions.net, laijs@cn.fujitsu.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	stephen@networkplumber.org, sbw@mit.edu, tgraf@suug.ch,
	akpm@linux-foundation.org, fengguang.wu@intel.com, davem@davemloft.net
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20131012065326.GG15339@leaf>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 11, 2013 at 11:53:27PM -0700, Josh Triplett wrote:
> On Fri, Oct 11, 2013 at 04:16:59PM -0700, Paul E. McKenney wrote:
> > Changes from v2:
> > 
> > o	Switch from rcu_assign_pointer() to ACCESS_ONCE() given that
> > 	the pointers are all --rcu and already visible to readers,
> > 	as suggested by Eric Dumazet and Josh Triplett.
> 
> Hang on a moment.  Do *none* of these cases need write memory barriers?

Sigh.  Some afternoons it doesn't pay to touch the keyboard.

Thank you for catching this.  I will fix, but at this point, I am thinking
in terms of 3.14 rather than 3.13 for this series.

							Thanx, Paul
