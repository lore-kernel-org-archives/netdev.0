From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3] net: macb: Fix more coding style issues
Date: Mon, 07 Mar 2016 09:25:38 -0800
Message-ID: <1457371538.4085.16.camel@perches.com>
References: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
	 <1457367460-9123-3-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Moritz Fischer <moritz.fischer@ettus.com>, nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0032.hostedemail.com ([216.40.44.32]:43972 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752427AbcCGRZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:25:43 -0500
In-Reply-To: <1457367460-9123-3-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-07 at 08:17 -0800, Moritz Fischer wrote:
> This commit takes care of the coding style warnings
> that are mostly due to a different comment style and
> lines over 80 chars.
[]
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
[]
> @@ -127,8 +126,7 @@ static void hw_writel(struct macb *bp, int offset=
, u32 value)
> =A0	writel_relaxed(value, bp->regs + offset);
> =A0}
> =A0
> -/*
> - * Find the CPU endianness by using the loopback bit of NCR register=
=2E When the
> +/* Find the CPU endianness by using the loopback bit of NCR register=
=2E When the
> =A0 * CPU is in big endian we need to program swaped mode for managem=
ent

swaped/swapped typo
@@ -945,6 +943,7 @@ static int macb_rx_frame(struct macb *bp, unsigned =
int first_frag,
> =A0static int macb_rx(struct macb *bp, int budget)
> =A0{
> =A0	int received =3D 0;
> +	int dropped;

This is an unnecessary and unmentioned change.

> =A0	unsigned int tail;
> =A0	int first_frag =3D -1;
> =A0
> @@ -968,7 +967,6 @@ static int macb_rx(struct macb *bp, int budget)
> =A0		}
> =A0
> =A0		if (ctrl & MACB_BIT(RX_EOF)) {
> -			int dropped;
> =A0			BUG_ON(first_frag =3D=3D -1);
> =A0
> =A0			dropped =3D macb_rx_frame(bp, first_frag, tail);
>=20
