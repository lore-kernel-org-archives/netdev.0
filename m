From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] slip: Use net_device_stats from struct net_device
Date: Fri, 27 Aug 2010 10:28:13 +0200
Message-ID: <1282897693.2487.2.camel@edumazet-laptop>
References: <1282811286-19659-1-git-send-email-tklauser@distanz.ch>
	 <1282896728-5211-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46987 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007Ab0H0I2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 04:28:18 -0400
Received: by wyb35 with SMTP id 35so3266663wyb.19
        for <netdev@vger.kernel.org>; Fri, 27 Aug 2010 01:28:16 -0700 (PDT)
In-Reply-To: <1282896728-5211-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 27 ao=C3=BBt 2010 =C3=A0 10:12 +0200, Tobias Klauser a =C3=A9=
crit :
> Use net_device->stats for stats instead of private variable copies in
> struct slip. Use ndo_get_stat64 so the additions can be performed on =
a private
> destination buffer.
>=20
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/slip.c |   61 ++++++++++++++++++++++++++----------------=
---------
>  drivers/net/slip.h |    9 -------
>  2 files changed, 31 insertions(+), 39 deletions(-)
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Tobias !



