From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ftmac100: use GFP_ATOMIC allocations
 where needed
Date: Sun, 13 Mar 2011 21:29:53 +0100
Message-ID: <1300048193.2761.55.camel@edumazet-laptop>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
	 <1300047388.2761.48.camel@edumazet-laptop>
	 <1300048002.2761.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50344 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab1CMU37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 16:29:59 -0400
In-Reply-To: <1300048002.2761.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 13 mars 2011 =C3=A0 21:26 +0100, Eric Dumazet a =C3=A9crit =
:
> Le dimanche 13 mars 2011 =C3=A0 21:16 +0100, Eric Dumazet a =C3=A9cri=
t :
>=20
> > BTW, it seems I missed the fact that ftmac100_alloc_rx_page() used =
a
> > GFP_KERNEL allocation, while its called from softirq context (from
> > ftmac100_rx_packet())=20
>=20
> Here is a patch against ftmac100
>=20

Oops, one typo in it sorry=20

> -static int ftmac100_alloc_rx_page(struct ftmac100 *priv, struct ftma=
c100_rxdes *rxdes)
> +static int ftmac100_alloc_rx_page(struct ftmac100 *priv,
> +				  struct ftmac100_rxdes *rxdes, gtp_t gfp)

Should be :   gfp_t gfp

Please build and test the patch, I dont have an ARM testbed anyway.

Thanks


