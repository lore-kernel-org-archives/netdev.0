From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] list: Fix order of arguments for hlist_add_after(_rcu)
Date: Fri, 6 Jun 2014 23:45:01 -0700
Message-ID: <20140606234501.b950d5d0.akpm@linux-foundation.org>
References: <1402047743-3391-1-git-send-email-kenhelias@firemail.de>
 <063D6719AE5E284EB5DD2968C1650D6D17258AEA@AcuExch.aculab.com>
 <20140606172250.GN4581@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
 "b.a.t.m.a.n@lists.open-mesh.org" <b.a.t.m.a.n@lists.open-mesh.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 'Ken Helias' <kenhelias@firemail.de>, lkml <linux-kernel@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 David Laight <David.Laight@aculab.com>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20140606172250.GN4581@linux.vnet.ibm.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

On Fri, 6 Jun 2014 10:22:51 -0700 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> On Fri, Jun 06, 2014 at 03:56:52PM +0000, David Laight wrote:
> > From: Behalf Of Ken Helias
> > > All other add functions for lists have the new item as first argument and the
> > > position where it is added as second argument. This was changed for no good
> > > reason in this function and makes using it unnecessary confusing.
> > > 
> > > Also the naming of the arguments in hlist_add_after was confusing. It was
> > > changed to use the same names as hlist_add_after_rcu.
> > ...
> > > -static inline void hlist_add_after_rcu(struct hlist_node *prev,
> > > -				       struct hlist_node *n)
> > > +static inline void hlist_add_after_rcu(struct hlist_node *n,
> > > +				       struct hlist_node *prev)
> > 
> > It is rather a shame that the change doesn't generate a compilation
> > error for old source files.
> 
> I am also a bit concerned by this.
> 

yup.  hlist_add_behind()?
