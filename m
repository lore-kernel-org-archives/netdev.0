From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Bugfix for packet drop with kernel param
 swiotlb=force
Date: Wed, 19 Feb 2014 16:44:16 -0500 (EST)
Message-ID: <20140219.164416.129376508868063340.davem@davemloft.net>
References: <OF433C3BAF.359D84C5-ON48257C84.002D80B1-48257C84.002E4C8C@zte.com.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com,
	wang.liang82@zte.com.cn, cai.qu@zte.com.cn, li.fengmao@zte.com.cn,
	long.chun@zte.com.cn
To: jiang.biao2@zte.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47069 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703AbaBSVoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 16:44:18 -0500
In-Reply-To: <OF433C3BAF.359D84C5-ON48257C84.002D80B1-48257C84.002E4C8C@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jiang.biao2@zte.com.cn
Date: Wed, 19 Feb 2014 16:25:40 +0800

> +        dma_unmap_page(&adapter->pdev->dev,
> +               dma_unmap_addr(rx_page_info, bus),
> +               rx_frag_size, DMA_FROM_DEVICE);

This is not indented properly.

Arguments on the second and subsequent lines of a function call must
start exactly at the first column after the openning parenthesis of the
function call on the first line.

You must use the appropriate number of TAB and SPACE characters
necessary to do so.

If you are indenting only using TAB characters, you are doing it wrong.
