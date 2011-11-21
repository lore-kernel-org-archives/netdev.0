From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/3] be2net: fix to display Pause
 autonegotiation setting
Date: Mon, 21 Nov 2011 17:10:45 +0000
Message-ID: <1321895445.2692.3.camel@bwh-desktop>
References: <20111121051240.GA17132@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43317 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993Ab1KURKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 12:10:50 -0500
In-Reply-To: <20111121051240.GA17132@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-11-20 at 23:12 -0600, Ajit Khaparde wrote:
> Pause autonegotiation is supported by default.
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> index 575c783..ff53489 100644
> --- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
> +++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> @@ -538,7 +538,7 @@ be_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
>  	struct be_adapter *adapter = netdev_priv(netdev);
>  
>  	be_cmd_get_flow_control(adapter, &ecmd->tx_pause, &ecmd->rx_pause);
> -	ecmd->autoneg = 0;
> +	ecmd->autoneg = 1;
>  }
>  
>  static int

This is surely not true for XFP and SFP+ interfaces.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
