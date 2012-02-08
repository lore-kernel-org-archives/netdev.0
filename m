From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [PATCH 11/50] ep93xx: use dev_hw_addr_random() instead of
 random_ether_addr()
Date: Wed, 8 Feb 2012 15:29:15 -0600
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F41F9DF286@AUSP01VMBX24.collaborationhost.net>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
 <1328735457-29986-12-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Danny Kukawka <dkukawka@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail127.messagelabs.com ([216.82.250.115]:51852 "EHLO
	mail127.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739Ab2BHVai convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 16:30:38 -0500
In-Reply-To: <1328735457-29986-12-git-send-email-danny.kukawka@bisect.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, February 08, 2012 2:10 PM, Danny Kukawka wrote:
>
> Use dev_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM
>
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
>  drivers/net/ethernet/cirrus/ep93xx_eth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
> index 4317af8..4b46270 100644
> --- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
> +++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
> @@ -859,7 +859,7 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
>  	ep->mdc_divisor = 40;	/* Max HCLK 100 MHz, min MDIO clk 2.5 MHz.  */
>  
>  	if (is_zero_ether_addr(dev->dev_addr))
> -		random_ether_addr(dev->dev_addr);
> +		dev_hw_addr_random(dev, dev->dev_addr);
>  
>  	err = register_netdev(dev);
>  	if (err) {

Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
