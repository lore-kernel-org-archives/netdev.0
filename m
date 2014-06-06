From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] list: Fix order of arguments for hlist_add_after(_rcu)
Date: Fri, 6 Jun 2014 10:22:51 -0700
Message-ID: <20140606172250.GN4581@linux.vnet.ibm.com>
References: <1402047743-3391-1-git-send-email-kenhelias@firemail.de>
 <063D6719AE5E284EB5DD2968C1650D6D17258AEA@AcuExch.aculab.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
 "b.a.t.m.a.n@lists.open-mesh.org" <b.a.t.m.a.n@lists.open-mesh.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 'Ken Helias' <kenhelias@firemail.de>, lkml <linux-kernel@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17258AEA@AcuExch.aculab.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 06, 2014 at 03:56:52PM +0000, David Laight wrote:
> From: Behalf Of Ken Helias
> > All other add functions for lists have the new item as first argument and the
> > position where it is added as second argument. This was changed for no good
> > reason in this function and makes using it unnecessary confusing.
> > 
> > Also the naming of the arguments in hlist_add_after was confusing. It was
> > changed to use the same names as hlist_add_after_rcu.
> ...
> > -static inline void hlist_add_after_rcu(struct hlist_node *prev,
> > -				       struct hlist_node *n)
> > +static inline void hlist_add_after_rcu(struct hlist_node *n,
> > +				       struct hlist_node *prev)
> 
> It is rather a shame that the change doesn't generate a compilation
> error for old source files.

I am also a bit concerned by this.

							Thanx, Paul
