From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_update
Date: Mon, 27 Jun 2011 00:07:37 -0700 (PDT)
Message-ID: <20110627.000737.395203330735191400.davem@davemloft.net>
References: <4da4117c-a24a-4512-9b79-fbed126e03bc@exht1.ad.emulex.com>
	<1309157789.2532.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sathya.perla@emulex.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756519Ab1F0HHp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 03:07:45 -0400
In-Reply-To: <1309157789.2532.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Jun 2011 08:56:29 +0200

> Le lundi 27 juin 2011 =E0 12:10 +0530, Sathya Perla a =E9crit :
>> Problem initially reproted and fixed by Eric Dumazet <eric.dumazet@g=
mail.com>
>>=20
>> netdev_stats_update() resets netdev->stats and then accumulates stat=
s from
>> various rings. This is wrong as stats readers can sometimes catch ze=
ro values.
>> Use temporary variables instead for accumulating per-ring values.
>>=20
>> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
>> ---
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
