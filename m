From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tunnel: eliminate recursion field
Date: Thu, 24 Sep 2009 15:47:10 -0700 (PDT)
Message-ID: <20090924.154710.248674101.davem@davemloft.net>
References: <4ABA8254.9000701@gmail.com>
	<4ABA84F1.5000802@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751289AbZIXWqv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2009 18:46:51 -0400
In-Reply-To: <4ABA84F1.5000802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Sep 2009 22:28:33 +0200

> Eric Dumazet a =E9crit :
>> It seems recursion field from "struct ip_tunnel" is not anymore need=
ed.
>> recursion prevention is done at the upper level (in dev_queue_xmit()=
),
>> since we use HARD_TX_LOCK protection for tunnels.
>>=20
>> This avoids a cache line ping pong on "struct ip_tunnel" : This stru=
cture
>> should be now mostly read on xmit and receive paths.
>=20
> Oops I forgot ipv6 tunnels, silly me, here is an updated version.
>=20
> Thanks
>=20
> [PATCH] tunnel: eliminate recursion field
>=20
> It seems recursion field from "struct ip_tunnel" is not anymore neede=
d.
> recursion prevention is done at the upper level (in dev_queue_xmit())=
,
> since we use HARD_TX_LOCK protection for tunnels.
>=20
> This avoids a cache line ping pong on "struct ip_tunnel" : This struc=
ture
> should be now mostly read on xmit and receive paths.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
