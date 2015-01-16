From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH] net: sxgbe: Fix waring for double kfree()
Date: Thu, 15 Jan 2015 19:14:16 -0500 (EST)
Message-ID: <20150115.191416.1303150560556013280.davem@davemloft.net>
References: <1421286191-9550-1-git-send-email-kgene@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.ne,
	dan.carpenter@oracle.com, bh74.an@samsung.com
To: kgene@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932309AbbAPAOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 19:14:17 -0500
In-Reply-To: <1421286191-9550-1-git-send-email-kgene@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kukjin Kim <kgene@kernel.org>
Date: Thu, 15 Jan 2015 10:43:11 +0900

> From: Byungho An <bh74.an@samsung.com>
> 
> This patch fixes double kfree() calls at init_rx_ring() because
> it causes static checker warning.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Byungho An <bh74.an@samsung.com>
> Signed-off-by: Kukjin Kim <kgene@kernel.org>

Applied.
