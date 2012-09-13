From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: Fix wrong usage of flush_work_sync while
 holding locks
Date: Thu, 13 Sep 2012 14:59:37 -0400 (EDT)
Message-ID: <20120913.145937.235693485700301637.davem@davemloft.net>
References: <1347546980-15923-1-git-send-email-keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: keil@b1-systems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521Ab2IMS7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 14:59:40 -0400
In-Reply-To: <1347546980-15923-1-git-send-email-keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <keil@b1-systems.de>
Date: Thu, 13 Sep 2012 16:36:20 +0200

> It is a bad idea to hold a spinlock and call flush_work_sync.
> Move the workqueue cleanup outside the spinlock and use cancel_work_sync,
> on closing the channel this seems to be the more correct function.
> Remove the never used and constant return value of mISDN_freebchannel.
> 
> Signed-off-by: Karsten Keil <keil@b1-systems.de>
> Cc: <stable@kernel.org>

Applied, thanks.
