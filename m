From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fec: fix the use of pdev->id
Date: Wed, 07 Dec 2011 13:38:33 -0500 (EST)
Message-ID: <20111207.133833.1526414845107847968.davem@davemloft.net>
References: <1323097275-7846-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: shawn.guo@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757560Ab1LGSkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 13:40:43 -0500
In-Reply-To: <1323097275-7846-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@linaro.org>
Date: Mon,  5 Dec 2011 23:01:15 +0800

> The pdev->id is used in several places for different purpose.  All
> these uses assume it's always the id of fec device which is >= 0.
> However this is only true for non-DT case.  When DT plays, pdev->id
> is always -1, which will break these pdev->id users.
> 
> Instead of fixing all these users one by one, this patch introduces
> a new member 'dev_id' to 'struct fec_enet_private' for holding the
> correct fec device id, and replaces all the existing uses of pdev->id
> with this dev_id.
> 
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>

Applied.
