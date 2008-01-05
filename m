From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sat, 05 Jan 2008 21:19:48 +1100
Message-ID: <1199528388.7291.55.camel@pasglop>
References: <1199526609-12290-1-git-send-email-sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35348 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060AbYAEKUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 05:20:07 -0500
In-Reply-To: <1199526609-12290-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2008-01-05 at 10:50 +0100, Stefan Roese wrote:
> Performance tests done by AMCC have shown that 256 buffer increase the
> performance of the Linux EMAC driver. So let's update the default
> values to match this setup.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---

Do we have the numbers ? Did they also measure latency ?

Ben.

>  drivers/net/ibm_newemac/Kconfig |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ibm_newemac/Kconfig b/drivers/net/ibm_newemac/Kconfig
> index 0d3e738..5a06727 100644
> --- a/drivers/net/ibm_newemac/Kconfig
> +++ b/drivers/net/ibm_newemac/Kconfig
> @@ -9,12 +9,12 @@ config IBM_NEW_EMAC
>  config IBM_NEW_EMAC_RXB
>  	int "Number of receive buffers"
>  	depends on IBM_NEW_EMAC
> -	default "128"
> +	default "256"
>  
>  config IBM_NEW_EMAC_TXB
>  	int "Number of transmit buffers"
>  	depends on IBM_NEW_EMAC
> -	default "64"
> +	default "256"
>  
>  config IBM_NEW_EMAC_POLL_WEIGHT
>  	int "MAL NAPI polling weight"

