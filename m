From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: Fix incorrect DMA unmapping size
Date: Fri, 06 Dec 2013 15:44:18 -0500 (EST)
Message-ID: <20131206.154418.1274102072648780863.davem@davemloft.net>
References: <1386261337-26442-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1386261337-26442-2-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, alior@marvell.com, w@1wt.eu,
	jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
	andrew@lunn.ch
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458Ab3LFUoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 15:44:20 -0500
In-Reply-To: <1386261337-26442-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Thu,  5 Dec 2013 13:35:37 -0300

> The current code unmaps the DMA mapping created for rx skb_buff's by
> using the data_size as the the mapping size. This is wrong since the
> correct size to specify should match the size used to create the mapping.
> 
> This commit removes the following DMA_API_DEBUG warning:
 ...
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Applied, thanks.
