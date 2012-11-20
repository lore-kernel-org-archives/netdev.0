From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 1/2] ixp4xx_eth: avoid calling dma_pool_create()
 with NULL dev
Date: Tue, 20 Nov 2012 15:13:24 -0500 (EST)
Message-ID: <20121120.151324.2243475860866740066.davem@davemloft.net>
References: <1353219910-24690-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, akpm@linux-foundation.org
To: xi.wang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680Ab2KTUN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 15:13:26 -0500
In-Reply-To: <1353219910-24690-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xi Wang <xi.wang@gmail.com>
Date: Sun, 18 Nov 2012 01:25:09 -0500

> Use &port->netdev->dev instead of NULL since dma_pool_create() doesn't
> allow NULL dev.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Applied.
