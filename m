From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: provide default_advmss() methods to blackhole
 dst_ops
Date: Fri, 18 Feb 2011 11:39:36 -0800 (PST)
Message-ID: <20110218.113936.193694941.davem@davemloft.net>
References: <AANLkTi=O1LZzSc8=qMX=R3rJpCVL8eWr1eo6NkiZXS0m@mail.gmail.com>
	<1298036005.6201.58.camel@edumazet-laptop>
	<1298036672.6201.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, linux@horizon.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, roland@purestorage.com, dbaluta@ixiacom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43020
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754845Ab1BRTjA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 14:39:00 -0500
In-Reply-To: <1298036672.6201.65.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Feb 2011 14:44:32 +0100

> Le vendredi 18 f=E9vrier 2011 =E0 14:33 +0100, Eric Dumazet a =E9crit=
 :
>=20
>> I had this exact idea but found we need struct net pointer to get th=
is
>> value, not provided in parameters, so I falled back to the 256 value=
=2E
>>=20
>>=20
>=20
> Hmm, reading again this stuff, maybe we can just use
> ipv4_default_advmss() instead of a custom one.
>=20
> dst->dev should be available
>=20
> [PATCH] net: provide default_advmss() methods to blackhole dst_ops
>=20
> Commit 0dbaee3b37e118a (net: Abstract default ADVMSS behind an
> accessor.) introduced a possible crash in tcp_connect_init(), when
> dst->default_advmss() is called from dst_metric_advmss()
>=20
> Reported-by: George Spelvin <linux@horizon.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Yes, this is a lot better, applied.

Thanks!
