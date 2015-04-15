From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 5/6] net: hip04: remove the unnecessary check
Date: Wed, 15 Apr 2015 16:14:26 +0200
Message-ID: <2645626.sX8mP7tn7R@wuerfel>
References: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com> <1429101008-9464-6-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, grant.likely@linaro.org,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	zhangfei.gao@linaro.org, joe@perches.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:55230 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968AbbDOOOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 10:14:40 -0400
In-Reply-To: <1429101008-9464-6-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 15 April 2015 20:30:07 Ding Tianhong wrote:
> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
> index ff9d19c..a7ab1d9 100644
> --- a/drivers/net/ethernet/hisilicon/hip04_eth.c
> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
> @@ -440,7 +440,7 @@ static int hip04_tx_reclaim(struct net_device *ndev, bool force)
>         smp_wmb(); /* Ensure tx_tail visible to xmit */
>  
>  out:
> -       if (pkts_compl || bytes_compl)
> +       if (bytes_compl)
>                 netdev_completed_queue(ndev, pkts_compl, bytes_compl);
>  
>         if (unlikely(netif_queue_stopped(ndev)) && (count < (TX_DESC_NUM - 1)))
> -- 
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
