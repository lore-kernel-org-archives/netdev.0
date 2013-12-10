From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 06/13] bna: UDP RX Processing Improvements
Date: Mon, 09 Dec 2013 19:17:55 -0500 (EST)
Message-ID: <20131209.191755.1735369355458133155.davem@davemloft.net>
References: <1386481724-32367-1-git-send-email-rmody@brocade.com>
	<1386481724-32367-7-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@Brocade.COM
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab3LJAR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 19:17:58 -0500
In-Reply-To: <1386481724-32367-7-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Sat, 7 Dec 2013 21:48:37 -0800

> @@ -233,13 +233,13 @@ struct bnad_tx_unmap {
>  struct bnad_rx_vector {
>  	DEFINE_DMA_UNMAP_ADDR(dma_addr);
>  	u32			len;
> -};
> +} __packed;

This is absolutely unacceptable, and at best not even mentioned in your
commit message.

There is no reason whatsoever to mark this structure as __packed.

I'm not applying this patch series, sorry.
