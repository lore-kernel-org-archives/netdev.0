From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] bnx2: make cnic_probe static
Date: Wed, 10 Apr 2013 15:27:32 -0700
Message-ID: <1365632852.2200.9.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <20130410135340.06f88645@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Stephen Hemminger" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2451 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762521Ab3DJW1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Apr 2013 18:27:38 -0400
In-Reply-To: <20130410135340.06f88645@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-10 at 13:53 -0700, Stephen Hemminger wrote: 
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Acked-by: Michael Chan <mchan@broadcom.com>

> 
> --- a/drivers/net/ethernet/broadcom/bnx2.c	2013-04-10 09:10:46.167617920 -0700
> +++ b/drivers/net/ethernet/broadcom/bnx2.c	2013-04-10 13:18:43.946608448 -0700
> @@ -416,7 +416,7 @@ static int bnx2_unregister_cnic(struct n
>  	return 0;
>  }
>  
> -struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev)
> +static struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev)
>  {
>  	struct bnx2 *bp = netdev_priv(dev);
>  	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
> 
