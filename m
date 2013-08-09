From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Fixed the condition of extend_desc for
 jumbo frame
Date: Fri, 09 Aug 2013 13:44:55 -0700 (PDT)
Message-ID: <20130809.134455.372438328661245407.davem@davemloft.net>
References: <004701ce9400$c4ba2f10$4e2e8d30$%an@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	kgene.kim@samsung.com, cpgs@samsung.com
To: bh74.an@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031057Ab3HIUo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 16:44:56 -0400
In-Reply-To: <004701ce9400$c4ba2f10$4e2e8d30$%an@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Byungho An <bh74.an@samsung.com>
Date: Thu, 08 Aug 2013 15:30:26 +0900

> This patch fixed the condition of extend_desc for jumbo frame. 
> There is no check routine for extend_desc in the stmmac_jumbo_frm function.
> Even though extend_desc is set if dma_tx is used instead of dma_etx.
> It causes kernel panic.
> 
> Signed-off-by: Byungho An <bh74.an@samsung.com>

Applied, thank you.
