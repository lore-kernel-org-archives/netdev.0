From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: udp: fix short packet and bad checksum logging
Date: Thu, 06 May 2010 16:48:00 +0200
Message-ID: <1273157280.2853.9.camel@edumazet-laptop>
References: <1273153475-32363-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:55389 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229Ab0EFOsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 10:48:07 -0400
Received: by bwz19 with SMTP id 19so20767bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 07:48:04 -0700 (PDT)
In-Reply-To: <1273153475-32363-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 15:44 +0200, Bj=C3=B8rn Mork a =C3=A9crit :
> commit 2783ef23 moved the initialisation of saddr and daddr after
> pskb_may_pull() to avoid a potential data corruption.  Unfortunately
> also placing it after the short packet and bad checksum error paths,
> where these variables are used for logging.  The result is bogus
> output like
>=20
> [92238.389505] UDP: short packet: From 2.0.0.0:65535 23715/178 to 0.0=
=2E0.0:65535
>=20
> Moving the saddr and daddr initialisation above the error paths, whil=
e still
> keeping it after the pskb_may_pull() to keep the fix from commit 2783=
ef23.
>=20
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> Cc: stable@kernel.org
> ---
>  net/ipv4/udp.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)

Well done :)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

To be backported to 2.6.29 and up kernels ;)



