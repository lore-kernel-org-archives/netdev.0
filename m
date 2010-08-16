From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: raw sockets rewriting IP ID in rare cases.
Date: Mon, 16 Aug 2010 08:26:25 +0200
Message-ID: <1281939985.2942.79.camel@edumazet-laptop>
References: <201008131307.38381.morgon.j.kanter@dartmouth.edu>
	 <20100814.223532.242143460.davem@davemloft.net>
	 <20100815135741.1iud2jvgw0wwg4kw@webmail.dartmouth.edu>
	 <20100815.131359.191392588.davem@davemloft.net>
	 <1281905220.2942.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Morgon.J.Kanter@Dartmouth.edu, netdev@vger.kernel.org,
	Jiri Olsa <jolsa@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>,
	Michael Kerrisk <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56724 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab0HPG0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 02:26:31 -0400
Received: by wyb32 with SMTP id 32so5300168wyb.19
        for <netdev@vger.kernel.org>; Sun, 15 Aug 2010 23:26:30 -0700 (PDT)
In-Reply-To: <1281905220.2942.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 15 ao=C3=BBt 2010 =C3=A0 22:47 +0200, Eric Dumazet a =C3=A9=
crit :

> Jiri Olsa added IP_NODEFRAG option some weeks ago (commit 7b2ff18e),
> we probably could implement IP_NOIDENT option for RAW sockets ?
>=20
>=20

Hmm, it seems we forgot to send to Michael some updates for
documentation.

http://www.kernel.org/doc/man-pages/online/pages/man7/ip.7.html

misses IP_FREEBIND, IP_IPSEC_POLICY, IP_XFRM_POLICY, IP_PASSSEC
IP_TRANSPARENT, IP_ORIGDSTADDR, IP_MINTTL and IP_NODEFRAG bits



