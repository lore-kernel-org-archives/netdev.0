From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] r8169:Fill with zero Tx descriptors
Date: Wed, 5 Aug 2015 15:57:21 +0300
Message-ID: <55C20831.30909@cogentembedded.com>
References: <1438771604-17621-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Corcodel Marian <corcodel.marian@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35897 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbbHEM5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 08:57:23 -0400
Received: by labgo9 with SMTP id go9so27934682lab.3
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 05:57:22 -0700 (PDT)
In-Reply-To: <1438771604-17621-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/5/2015 1:46 PM, Corcodel Marian wrote:

>   This patch fill with zero Tx descriptors before use.Is only
>   on    part by more patches but is critical.(critical)


> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 3df51fa..bf78f94 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7589,7 +7589,7 @@ static int rtl_open(struct net_device *dev)
>   	 * Rx and Tx descriptors needs 256 bytes alignment.
>   	 * dma_alloc_coherent provides more.
>   	 */
> -	tp->TxDescArray = dma_alloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
> +	tp->TxDescArray = dma_zalloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
>   					     &tp->TxPhyAddr, GFP_KERNEL);

    Please re-align the continuation line.

[...]

MBR, Sergei
