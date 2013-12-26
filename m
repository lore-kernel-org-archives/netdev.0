From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 5/6] bnx2x: Add num of VFs to Management
 statistics
Date: Thu, 26 Dec 2013 11:18:31 -0800
Message-ID: <1388085511.12212.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
	 <1388044632-9172-6-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ariele@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:58911 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661Ab3LZTSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 14:18:33 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so8457760pbc.21
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 11:18:32 -0800 (PST)
In-Reply-To: <1388044632-9172-6-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-26 at 09:57 +0200, Yuval Mintz wrote:
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 72973cc..094dfc8 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -3298,6 +3298,8 @@ static void bnx2x_drv_info_ether_stat(struct bnx2x *bp)
>  
>  	ether_stat->txq_size = bp->tx_ring_size;
>  	ether_stat->rxq_size = bp->rx_ring_size;
> +
> +	ether_stat->vf_cnt = IS_SRIOV(bp) ? bp->vfdb->sriov.nr_virtfn : 0;
>  }
>  
>  static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)


This patch broke my builds here.

Probably because I do not have CONFIG_BNX2X_SRIOV
