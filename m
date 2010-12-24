From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] netfilter: ebtables: make broute table work again
Date: Fri, 24 Dec 2010 01:55:50 +0100
Message-ID: <20101224005550.GA14050@strlen.de>
References: <1293150436-12092-1-git-send-email-fw@strlen.de>
 <AANLkTikgoc6xzx-0xn4cXsVuWVETOG1=dpE_1kZKBVnM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikgoc6xzx-0xn4cXsVuWVETOG1=dpE_1kZKBVnM@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changli Gao <xiaosuo@gmail.com> wrote:
> > diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> > index 6f6d8e1..1d677bf 100644
> > --- a/net/bridge/br_input.c
> > +++ b/net/bridge/br_input.c
> > @@ -178,7 +178,7 @@ forward:
> > =A0 =A0 =A0 =A0case BR_STATE_FORWARDING:
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rhook =3D rcu_dereference(br_should_=
route_hook);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (rhook) {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((*rhook)(skb))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rhook(skb))
>=20
> I don't think this change is necessary. Would you like to remove this
> change and test again?

Its not needed, but i consider it less confusing.
I do not have a strong preference, though.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
