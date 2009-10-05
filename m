From: Atis Elsts <atis@mikrotik.com>
Subject: Re: [PATCH] Use sk_mark for IPv6 routing lookups
Date: Mon, 5 Oct 2009 15:55:41 +0300
Message-ID: <200910051555.41543.atis@mikrotik.com>
References: <200910011814.47689.atis@mikrotik.com> <55a4f86e0910021025u7523029av1e4ee917d1fb1ee5@mail.gmail.com> <4AC64419.6020202@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?utf-8?q?=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.196]:50563 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932367AbZJEM4X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 08:56:23 -0400
In-Reply-To: <4AC64419.6020202@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 02 October 2009 21:19:05 Brian Haley wrote:
> Maciej =C5=BBenczykowski wrote:
> > Cool!
> >=20
> > As I've already pointed out in a post 2 or so weeks ago, we need th=
e
> > exact same treatment in a ton of places throughout the code (tcp,
> > ipv6, decnet, etc...).
>=20
> Here's a try at the IPv6 part...
>=20
>=20
> Add support for IPv6 route lookups using sk_mark.
>=20

Not sure if there is need to fill the mark from skb in tunnel xmit func=
tions. In any case, it's not done for GRE or IPIP tunnels at the moment=
=2E

Also, in this patch you are doing that for SIT (v6-in-v4) tunnels only,=
 and not doing it for v4-in-v6 or v6-in-v6 tunnels. Any reason for that=
?

Atis
