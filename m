From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/9] infiniband: addr: Consolidate code to fetch
 neighbout hardware address from dst.
Date: Sat, 03 Dec 2011 08:30:09 +0100
Message-ID: <1322897409.2762.80.camel@edumazet-laptop>
References: <20111202.215214.2206154836146990479.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39310 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab1LCHaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 02:30:13 -0500
Received: by wgbdr13 with SMTP id dr13so2768966wgb.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 23:30:12 -0800 (PST)
In-Reply-To: <20111202.215214.2206154836146990479.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 21:52 -0500, David Miller a =C3=
=A9crit :
> IPV4 should do exactly what the IPV6 code does here, which is
> use the neighbour obtained via the dst entry.
>=20
> And now that the two code paths do the same thing, use a common
> helper function to perform the operation.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/infiniband/core/addr.c |   47 +++++++++++++++++-------------=
---------
>  1 files changed, 21 insertions(+), 26 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
