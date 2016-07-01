From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: ethernet: ti: davinci_cpdma: split descs num
 between all channels
Date: Fri, 01 Jul 2016 16:35:06 -0400 (EDT)
Message-ID: <20160701.163506.323242842287789721.davem@davemloft.net>
References: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
	<1467313478-22919-2-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, nsekhar@ti.com
To: ivan.khoronzhuk@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbcGAUnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 16:43:08 -0400
In-Reply-To: <1467313478-22919-2-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Thu, 30 Jun 2016 22:04:35 +0300

> @@ -720,7 +763,7 @@ unlock_ret:
>  }
>  EXPORT_SYMBOL_GPL(cpdma_chan_submit);
>  
> -bool cpdma_check_free_tx_desc(struct cpdma_chan *chan)
> +inline bool cpdma_check_free_desc(struct cpdma_chan *chan)
>  {

This needs to be marked static.
