From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: add limits to ip_default_ttl
Date: Mon, 13 Dec 2010 12:18:03 -0800 (PST)
Message-ID: <20101213.121803.48496655.davem@davemloft.net>
References: <20101213.100400.39192396.davem@davemloft.net>
	<1292270912.2679.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42300
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753183Ab0LMURg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 15:17:36 -0500
In-Reply-To: <1292270912.2679.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Dec 2010 21:08:32 +0100

> Le lundi 13 d=E9cembre 2010 =E0 10:04 -0800, David Miller a =E9crit :
>> Always go through a new ip4_dst_hoplimit() helper, just like ipv6.
 ...
> Please find following patch then, because extra2 is not anymore used.

Ok.

> BTW, I cant find where extra2 was set to actual struct net pointer in
> net-2.6 kernel. I suspect a write on /proc/sys/net/ipv4/ip_default_tt=
l
> was flushing routes of initial net only, not current one ?

It appears that way.

> [PATCH net-next-2.6] net: add limits to ip_default_ttl
>=20
> ip_default_ttl should be between 1 and 255
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
