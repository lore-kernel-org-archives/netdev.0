From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_update
Date: Mon, 27 Jun 2011 08:56:29 +0200
Message-ID: <1309157789.2532.77.camel@edumazet-laptop>
References: <4da4117c-a24a-4512-9b79-fbed126e03bc@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62651 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906Ab1F0G4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 02:56:37 -0400
Received: by wyg8 with SMTP id 8so869701wyg.19
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 23:56:36 -0700 (PDT)
In-Reply-To: <4da4117c-a24a-4512-9b79-fbed126e03bc@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 27 juin 2011 =C3=A0 12:10 +0530, Sathya Perla a =C3=A9crit :
> Problem initially reproted and fixed by Eric Dumazet <eric.dumazet@gm=
ail.com>
>=20
> netdev_stats_update() resets netdev->stats and then accumulates stats=
 from
> various rings. This is wrong as stats readers can sometimes catch zer=
o values.
> Use temporary variables instead for accumulating per-ring values.
>=20
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks


