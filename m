From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/4] tcpv6: trivial formatting changes to
	send_(ack|reset)
Date: Thu, 9 Oct 2008 11:16:58 -0300
Message-ID: <20081009141658.GB24905@ghostprotocols.net>
References: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi> <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi> <20081009.185230.46697834.yoshfuji@linux-ipv6.org> <Pine.LNX.4.64.0810091254160.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57313 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753135AbYJIOUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 10:20:50 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810091254160.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Oct 09, 2008 at 12:58:07PM +0300, Ilpo J=E4rvinen escreveu:
> On Thu, 9 Oct 2008, YOSHIFUJI Hideaki / ???? wrote:
>=20
> > In article <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsink=
i.fi> (at Thu,  9 Oct 2008 12:35:35 +0300), "Ilpo J=E4rvinen" <ilpo.jar=
vinen@helsinki.fi> says:
> >=20
> > > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> > > ---
> > >  net/ipv6/tcp_ipv6.c |    7 +++----
> > >  1 files changed, 3 insertions(+), 4 deletions(-)
> > >=20
> > > diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> > > index 2084f5a..3f268a3 100644
> > > --- a/net/ipv6/tcp_ipv6.c
> > > +++ b/net/ipv6/tcp_ipv6.c
> > > @@ -948,7 +948,7 @@ static void tcp_v6_send_reset(struct sock *sk=
, struct sk_buff *skb)
> > >  	struct flowi fl;
> > >  	struct net *net =3D dev_net(skb->dst->dev);
> > >  	struct sock *ctl_sk =3D net->ipv6.tcp_sk;
> > > -	unsigned int tot_len =3D sizeof(*th);
> > > +	unsigned int tot_len =3D sizeof(struct tcphdr);
> > >  #ifdef CONFIG_TCP_MD5SIG
> > >  	struct tcp_md5sig_key *key;
> > >  #endif
> >=20
> > I usually prefer sizeof(var) (or sizeof(*ptr)) over sizeof(type).
> > Could you justify this change?
>=20
> My point was to make those two functions as equal as possible before =
merge=20
> so that it's more easier to track what happens at the merge, both=20
> versions pre-existed anyway. Sure I don't have much opinion either wa=
y.

I agree with Yoshifuji, albeit it is unlikely that the type of that
variable will change 8)

- Arnaldo
