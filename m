From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
	matching table
Date: Wed, 16 Jan 2008 20:53:59 +1100
Message-ID: <1200477239.6755.21.camel@pasglop>
References: <1200476230-14026-1-git-send-email-sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53717 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753065AbYAPJyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 04:54:25 -0500
In-Reply-To: <1200476230-14026-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-01-16 at 10:37 +0100, Stefan Roese wrote:
> With the removal the the "rgmii-interface" device_type property from the
> dts files, the newemac driver needs an update to only rely on compatible
> property.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>

I need to test if it works on CAB, can't change the DT on those. I'll
let you know tomorrow.

> ---
>  drivers/net/ibm_newemac/rgmii.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ibm_newemac/rgmii.c
> index 9bc1132..5757788 100644
> --- a/drivers/net/ibm_newemac/rgmii.c
> +++ b/drivers/net/ibm_newemac/rgmii.c
> @@ -302,7 +302,6 @@ static int __devexit rgmii_remove(struct of_device *ofdev)
>  static struct of_device_id rgmii_match[] =
>  {
>  	{
> -		.type		= "rgmii-interface",
>  		.compatible	= "ibm,rgmii",
>  	},
>  	{

