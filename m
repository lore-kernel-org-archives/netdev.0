From: "David S. Miller" <davem@davemloft.net>
Subject: (usagi-users 03617) Re: [PATCH] ip6_tunnel: release cached dst on change of tunnel
 params
Date: Fri, 24 Feb 2006 13:16:57 -0800 (PST)
Message-ID: <20060224.131657.32700712.davem@davemloft.net>
References: <20060224015046.GQ1194@innerghost.net>
	<43FF104B.1090006@tcs.hut.fi>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: vnuorval@tcs.hut.fi
In-Reply-To: <43FF104B.1090006@tcs.hut.fi>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Fri, 24 Feb 2006 15:55:23 +0200

> Hugo Santos wrote:
> > Hi,
> > 
> >    The included patch fixes ip6_tunnel to release the cached dst entry
> >  when the tunnel parameters (such as tunnel endpoints) are changed so
> >  they are used immediatly for the next encapsulated packets.
> > 
> >  Signed-off-by: Hugo Santos <hsantos@av.it.pt>
> > 
> > --- linux-2.6.16-rc4/net/ipv6/ip6_tunnel.c      2006-02-17 22:23:45.000000000 +0000
> > +++ linux-2.6.16-rc4-new/net/ipv6/ip6_tunnel.c  2006-02-24 01:40:17.000000000 +0000
> > @@ -884,6 +884,7 @@ ip6ip6_tnl_change(struct ip6_tnl *t, str
> >         t->parms.encap_limit = p->encap_limit;
> >         t->parms.flowinfo = p->flowinfo;
> >         t->parms.link = p->link;
> > +       ip6_tnl_dst_reset(t);
> >         ip6ip6_tnl_link_config(t);
> >         return 0;
> >  }
> > 
> Acked-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Applied, although the patch was tab/whitespace damaged by Hugo's
email client so I had to apply it by hand.
