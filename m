From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 net-next] bnx2: Add missing memory barrier in
 bnx2_start_xmit()
Date: Sun, 05 Feb 2012 22:46:44 -0500 (EST)
Message-ID: <20120205.224644.911937990752945293.davem@davemloft.net>
References: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
	<1328491480-13030-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260Ab2BFDrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 22:47:16 -0500
In-Reply-To: <1328491480-13030-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 5 Feb 2012 17:24:39 -0800

> From: Vlad Zolotarov <vlad@scalemp.com>
> 
> Sync DMA descriptor before hitting the TX mailbox for weak memory model
> CPUs.
> 
> There has been discussions several years ago about this.  Some believe
> that writel() should guarantee ordering.  Others want explicit barriers
> if necessary.  Today writel() does not have the ordering guarantee and
> many other drivers use explicit barriers.
> 
> Signed-off-by: Vlad Zolotarov <vlad@scalemp.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
