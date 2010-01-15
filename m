From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Fri, 15 Jan 2010 07:57:56 +0100
Message-ID: <4B5011F4.8010204@gmail.com>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>	 <412e6f7f1001141822pffa070ap15c73e2931402294@mail.gmail.com>	 <4B5008F5.6090007@gmail.com> <412e6f7f1001142239n704d2827q614f59255e85e328@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39465 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790Ab0AOG6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 01:58:07 -0500
In-Reply-To: <412e6f7f1001142239n704d2827q614f59255e85e328@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/01/2010 07:39, Changli Gao a =C3=A9crit :
> The code bellow is from my ifb-mq.patch
> #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>         case __constant_htons(ETH_P_IPV6):
> process_ipv6:
>                 if (unlikely(!pskb_may_pull(skb, sizeof(struct ipv6hd=
r))))
>                         goto process_other;
>                 addr1 =3D ipv6_hdr(skb)->saddr.s6_addr32[3];
>                 addr2 =3D ipv6_hdr(skb)->daddr.s6_addr32[3];
>                 ihl =3D ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr),=
 &ip_proto);
>                 if (unlikely(ihl < 0))
>                         goto process_other_trans;
>                 break;
> #endif
>=20
>=20

Thanks Changli !

