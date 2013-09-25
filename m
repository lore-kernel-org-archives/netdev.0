From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH tip/core/rcu 04/13] wireless: Apply
 rcu_access_pointer() to avoid sparse false positive
Date: Wed, 25 Sep 2013 11:26:08 -0700
Message-ID: <20130925182608.GY9093@linux.vnet.ibm.com>
References: <20130925013451.GA31260@linux.vnet.ibm.com>
	<1380072916-31557-1-git-send-email-paulmck@linux.vnet.ibm.com>
	<1380072916-31557-4-git-send-email-paulmck@linux.vnet.ibm.com>
	<1380131303.2222.9.camel@bwh-desktop.uk.level5networks.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>, tglx@linutronix.de,
	laijs@cn.fujitsu.com, edumazet@google.com,
	"David S. Miller" <davem@davemloft.net>, peterz@infradead.org,
	fweisbec@gmail.com, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, rostedt@goodmis.org,
	josh@joshtriplett.org, dhowells@redhat.com, sbw@mit.edu,
	niv@us.ibm.com, netdev@vger.kernel.org,
	mathieu.desnoyers@efficios.com, dipankar@in.ibm.com,
	darren@dvhart.com, akpm@linux-foundation.org, mingo@kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1380131303.2222.9.camel@bwh-desktop.uk.level5networks.com>
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

On Wed, Sep 25, 2013 at 06:48:23PM +0100, Ben Hutchings wrote:
> On Tue, 2013-09-24 at 18:35 -0700, Paul E. McKenney wrote:
> > From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> > 
> > The sparse checking for rcu_assign_pointer() was recently upgraded
> > to reject non-__kernel address spaces.  This also rejects __rcu,
> > which is almost always the right thing to do.  However, the uses in
> > cfg80211_combine_bsses() and cfg80211_bss_update() are legitimate:
> > They is assigning a pointer to an element from an RCU-protected list,
> [...]
> 
> 'They is'?  This error is also in the commit messsages for the bridge
> and mac80211 patches, and maybe others that weren't sent to netdev.

Good catch, fixed in four patches.  Yeah, English can be a bit
unfriendly at times to text reuse.  The s/It/They/ should have been
s/It is/They are/.  ;-)

							Thanx, Paul
