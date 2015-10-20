From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-next v3] bnxt_en: New Broadcom ethernet driver.
Date: Tue, 20 Oct 2015 16:09:48 -0400
Message-ID: <20151020200948.GE23569@tuxdriver.com>
References: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, prashant@broadcom.com, eddie.wai@broadcom.com,
	huangjw@broadcom.com, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44760 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbJTUPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 16:15:16 -0400
Content-Disposition: inline
In-Reply-To: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 17, 2015 at 12:21:44AM -0400, Michael Chan wrote:
> Broadcom ethernet driver for the new family of NetXtreme-C/E
> ethernet devices.
> 
> v3:
>   - Fixed 2 more sparse warnings.
>   - Removed some unused structures in .h files.
> 
> v2:
>   - Fixed all kbuild test robot reported warnings.
>   - Fixed many of the checkpatch.pl errors and warnings.
>   - Fixed the Kconfig description.
> 
> Acked-by: Eddie Wai <eddie.wai@broadcom.com>
> Acked-by: Jeffrey Huang <huangjw@broadcom.com>
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

...

> +		if (netif_msg_drv(bp))
> +			netdev_info(bp->dev, "[%d]: tx{fw_ring: %d prod: %x cons: %x} rx{fw_ring: %d prod: %x} rx_agg{fw_ring: %d agg_prod: %x sw_agg_prod: %x} cp{fw_ring: %d raw_cons: %x}\n",
> +				    i, txr->tx_ring_struct.fw_ring_id,
> +				    txr->tx_prod, txr->tx_cons,
> +				    rxr->rx_ring_struct.fw_ring_id,
> +				    rxr->rx_prod,
> +				    rxr->rx_agg_ring_struct.fw_ring_id,
> +				    rxr->rx_agg_prod, rxr->rx_sw_agg_prod,
> +				    cpr->cp_ring_struct.fw_ring_id,
> +				    cpr->cp_raw_cons);

Another big string -- perhaps a few \n's are in order?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
