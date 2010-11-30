From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Tue, 30 Nov 2010 17:53:46 +0100
Message-ID: <1291136026.2904.135.camel@edumazet-laptop>
References: <20101130163057.29978.92721.stgit@rechot.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>, Jon Mason <jon.mason@exar.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: =?UTF-8?Q?Micha=C5=82Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35192 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab0K3Qxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 11:53:51 -0500
Received: by wyb28 with SMTP id 28so5889266wyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 08:53:50 -0800 (PST)
In-Reply-To: <20101130163057.29978.92721.stgit@rechot.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 17:38 +0100, Micha=C5=82Miros=C5=82aw =
a =C3=A9crit :
> NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM, b=
ut
> some drivers miss the difference. Fix this and also fix UFO dependenc=
y
> on checksumming offload as it makes the same mistake in assumptions.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>=20
> Changes from v1:
> - fixed compilation of jme driver
> - enable vxge support for IPv6 checksum
> ---
>  drivers/net/vxge/vxge-ethtool.c |    2 +-
>  drivers/net/vxge/vxge-main.c    |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

I have no idea how you got this diffstat.

Your patch touches more files than that...


