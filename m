From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix hang in dmfe driver on sending of big packet
 (linux-2.6.35)
Date: Thu, 02 Dec 2010 13:24:47 -0800 (PST)
Message-ID: <20101202.132447.232754988.davem@davemloft.net>
References: <20101130134626.GA1856@lw.yar.ru>
	<1291125459.2904.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lav@netis.ru, netdev@vger.kernel.org, tori@unhappy.mine.nu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35086
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758115Ab0LBVYV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 16:24:21 -0500
In-Reply-To: <1291125459.2904.75.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Nov 2010 14:57:39 +0100

> From: Alexander V. Lukyanov <lav@netis.ru>
>=20
> Le mardi 30 novembre 2010 =E0 16:46 +0300, Alexander V. Lukyanov a =E9=
crit :
>> Hello!
>>=20
>> This patch fixes hang in dmfe driver on attempt of sending a big pac=
ket.
>> Without this patch the code stops the queue and never wakes it again=
=2E
>>=20
>> Signed-off-by: Alexander V. Lukyanov <lav@netis.ru>
>>=20
>=20
> Nice catch, but your patch is not a "diff -p1" one
>=20
> I did it for net-2.6 tree :
>=20
> Thanks
>=20
> [PATCH] tulip: fix hang in dmfe driver on sending of big packet
>=20
> This patch fixes hang in dmfe driver on attempt of sending a big pack=
et.
> Without this patch the code stops the queue and never wakes it again.
>=20
> Signed-off-by: Alexander V. Lukyanov <lav@netis.ru>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
