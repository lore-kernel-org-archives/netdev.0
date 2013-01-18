From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/1] net: ethernet: davinci_cpdma: Add boundary for
 rx and tx descriptors
Date: Fri, 18 Jan 2013 14:28:39 -0500 (EST)
Message-ID: <20130118.142839.1967485391237728493.davem@davemloft.net>
References: <1358440294-13676-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ART2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:28:41 -0500
In-Reply-To: <1358440294-13676-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 17 Jan 2013 22:01:34 +0530

> When there is heavy transmission traffic in the CPDMA, then Rx descriptors
> memory is also utilized as tx desc memory looses all rx descriptors and the
> driver stops working then.
> 
> This patch adds boundary for tx and rx descriptors in bd ram dividing the
> descriptor memory to ensure that during heavy transmission tx doesn't use
> rx descriptors.
> 
> This patch is already applied to davinci_emac driver, since CPSW and
> davici_dmac shares the same CPDMA, moving the boundry seperation from
> Davinci EMAC driver to CPDMA driver which was done in the following
> commit
> 
> commit 86d8c07ff2448eb4e860e50f34ef6ee78e45c40c
> Author: Sascha Hauer <s.hauer@pengutronix.de>
> Date:   Tue Jan 3 05:27:47 2012 +0000
> 
>     net/davinci: do not use all descriptors for tx packets
 ...
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied to net-next, thanks.
