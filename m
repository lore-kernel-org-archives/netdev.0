From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.35, netfilter/iptables not working with 32bit userspace +
 64bit kernel?
Date: Fri, 13 Aug 2010 14:18:05 +0200
Message-ID: <1281701885.4470.22.camel@edumazet-laptop>
References: <20100813134706.509472n222yo71d6@hayate.sektori.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51110 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934206Ab0HMMSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 08:18:10 -0400
In-Reply-To: <20100813134706.509472n222yo71d6@hayate.sektori.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC netfilter-devel to get more people in touch

Thanks !

Le vendredi 13 ao=C3=BBt 2010 =C3=A0 13:47 +0300, Jussi Kivilinna a =C3=
=A9crit :
> Hello!
>=20
> I have server/firewall running Debian lenny with 32bit userspace and =
=20
> 64bit kernel. After upgrading from 2.6.34 to 2.6.35, I couldn't get =20
> any new chains work. Simply doing (with 32bit iptables)
>=20
>    iptables -N new_chain
>    iptables -A OUTPUT -j new_chain
>    iptables -A OUTPUT -j ACCEPT
>=20
> cause output to freeze. "iptables -L -vn" shows:
>=20
> Chain OUTPUT (policy ACCEPT 3397 packets, 637K bytes)
>   pkts bytes target     prot opt in     out     source         destin=
ation
>      3   252 new_chain  all  --  *      *       0.0.0.0/0      0.0.0.=
0/0
>      0     0 ACCEPT     all  --  *      *       0.0.0.0/0      0.0.0.=
0/0
>=20
> Ping shows "ping: sendmsg: Operation not permitted".
>=20
> With recompiled 64bit iptables, example above works fine.
>=20
> -Jussi
>=20
> --

