From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iptables: use skb->len for accounting
Date: Fri, 23 Jul 2010 14:14:13 +0200
Message-ID: <1279887253.2481.3.camel@edumazet-laptop>
References: <1279856088-9004-1-git-send-email-xiaosuo@gmail.com>
	 <1279866541.2482.79.camel@edumazet-laptop>
	 <AANLkTikFp9tjtYz5c0GTOfcS1DD8v6fLvBUVVeBVbsns@mail.gmail.com>
	 <1279868302.2482.113.camel@edumazet-laptop>  <4C4981B7.2090101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C4981B7.2090101@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 23 juillet 2010 =C3=A0 13:49 +0200, Patrick McHardy a =C3=A9=
crit :


> Actually skb->len is also exact at the IPv4 level. I'm inclined
> to apply this patch for consistency with ip6_tables, where using
> skb->len fixes jumbo frame accounting.
>=20

Thats right.

I was confused by recent problem raised with UDP checksums.

But pskb_trim_rcsum() is indeed called from ip_rcv() so
skb->len =3D=3D ntohs(iph->tot_len)

Thanks


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
