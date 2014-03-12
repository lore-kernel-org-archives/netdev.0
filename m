From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V4 3/9] Altera TSE: Add Altera Ethernet Driver
 MSGDMA File Components
Date: Wed, 12 Mar 2014 13:31:15 -0700
Message-ID: <1394656275.3915.32.camel@joe-AO722>
References: <1394655334-29547-1-git-send-email-vbridgers2013@gmail.com>
	 <1394655334-29547-4-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0184.hostedemail.com ([216.40.44.184]:36450 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751142AbaCLUbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:31:19 -0400
In-Reply-To: <1394655334-29547-4-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-12 at 15:15 -0500, Vince Bridgers wrote:
> This patch adds the MSGDMA soft IP support for the Altera Triple
> Speed Ethernet driver.

[]

> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> V4: - Modify use of dev_* to netdev_* where possible

Hi again Vince.

trivia:

It'd be better to also use the netif_<foo> forms too.

This can be done later in a follow-on patch if desired.

> diff --git a/drivers/net/ethernet/altera/altera_msgdma.c b/drivers/net/ethernet/altera/altera_msgdma.c
[]
> +void msgdma_reset(struct altera_tse_private *priv)
> +{
[]
> +	if ((counter >= ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) &&
> +	    (netif_msg_drv(priv)))
> +		netdev_warn(priv->dev,
> +			    "TSE Rx mSGDMA resetting bit never cleared!\n");

	if (counter >= ALTERA_TSE_SW_RESET_WATCHDOG_CNTR)
		netif_warn(priv, drv, priv->dev,
			   "TSE Rx mSGDMA resetting bit never cleared!\n");

[]

> +	if ((counter >= ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) &&
> +	    (netif_msg_drv(priv)))
> +		netdev_warn(priv->dev,
> +			    "TSE Tx mSGDMA resetting bit never cleared!\n");

	if (counter >= ALTERA_TSE_SW_RESET_WATCHDOG_CNTR)
		netif_warn(priv, drv, priv->dev,
			   "TSE Tx mSGDMA resetting bit never cleared!\n");

cheers, Joe
