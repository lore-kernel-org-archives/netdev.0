From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] can: convert protocol handling to RCU
Date: Mon, 04 Apr 2011 22:26:10 +0200
Message-ID: <1301948770.3021.41.camel@edumazet-laptop>
References: <4D9A2844.2080304@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Urs Thuermann <urs@isnogud.escape.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52979 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960Ab1DDU0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 16:26:16 -0400
Received: by wwa36 with SMTP id 36so6903220wwa.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 13:26:15 -0700 (PDT)
In-Reply-To: <4D9A2844.2080304@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 avril 2011 =C3=A0 22:21 +0200, Oliver Hartkopp a =C3=A9crit=
 :
> This patch removes spin_locks at CAN socket creation time by using RC=
U.
>=20
> Inspired by the discussion with Kurt van Dijck and Eric Dumazet the R=
CU code
> was partly derived from af_phonet.c
>=20
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>=20
> ---
>=20
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index 733d66f..551ebc1 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -85,7 +85,7 @@ static struct kmem_cache *rcv_cache __read_mostly;

Seems good to me, thanks !

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>



