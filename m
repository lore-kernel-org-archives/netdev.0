From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: Add better comment for RXUBR handling
Date: Fri, 15 May 2015 09:49:07 +0200
Message-ID: <5555A4F3.40703@atmel.com>
References: <1431554496-11716-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Nathan Sullivan <nathan.sullivan@ni.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:57723 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932900AbbEOHuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 03:50:06 -0400
In-Reply-To: <1431554496-11716-1-git-send-email-nathan.sullivan@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/05/2015 00:01, Nathan Sullivan a =E9crit :
> Describe the handler for RXUBR better with a new comment.
>=20
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> Reviewied-by: Josh Cartwright <joshc@ni.com>
> Reviewied-by: Ben Shelton <ben.shelton@ni.com>

Thanks Nathan: good that you've added this comment!

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.c |    6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 61aa570..5f10dfc 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1037,6 +1037,12 @@ static irqreturn_t macb_interrupt(int irq, voi=
d *dev_id)
>  		 * add that if/when we get our hands on a full-blown MII PHY.
>  		 */
> =20
> +		/* There is a hardware issue under heavy load where DMA can
> +		 * stop, this causes endless "used buffer descriptor read"
> +		 * interrupts but it can be cleared by re-enabling RX. See
> +		 * the at91 manual, section 41.3.1 or the Zynq manual
> +		 * section 16.7.4 for details.
> +		 */
>  		if (status & MACB_BIT(RXUBR)) {
>  			ctrl =3D macb_readl(bp, NCR);
>  			macb_writel(bp, NCR, ctrl & ~MACB_BIT(RE));
>=20


--=20
Nicolas Ferre
