From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH nf-next] ipset: remove unused function
 __ip_set_get_netlink
Date: Fri, 14 Apr 2017 16:15:41 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1704141612410.5084@blackhole.kfki.hu>
References: <20170410195237.19909-1-aconole@bytheb.org> <20170413232842.GC7721@salvia>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Aaron Conole <aconole@bytheb.org>,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170413232842.GC7721@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

On Fri, 14 Apr 2017, Pablo Neira Ayuso wrote:

> On Mon, Apr 10, 2017 at 03:52:37PM -0400, Aaron Conole wrote:
> > There are no in-tree callers.
> 
> @Jozsef, let me know if I should just take this to save you a pull
> request.

Just take it, thank you.

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Best regards,
Jozsef

> > Signed-off-by: Aaron Conole <aconole@bytheb.org>
> > ---
> >  net/netfilter/ipset/ip_set_core.c | 8 --------
> >  1 file changed, 8 deletions(-)
> > 
> > diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
> > index c296f9b..68ba531 100644
> > --- a/net/netfilter/ipset/ip_set_core.c
> > +++ b/net/netfilter/ipset/ip_set_core.c
> > @@ -501,14 +501,6 @@ __ip_set_put(struct ip_set *set)
> >   * a separate reference counter
> >   */
> >  static inline void
> > -__ip_set_get_netlink(struct ip_set *set)
> > -{
> > -	write_lock_bh(&ip_set_ref_lock);
> > -	set->ref_netlink++;
> > -	write_unlock_bh(&ip_set_ref_lock);
> > -}
> > -
> > -static inline void
> >  __ip_set_put_netlink(struct ip_set *set)
> >  {
> >  	write_lock_bh(&ip_set_ref_lock);
> > -- 
> > 2.9.3
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
