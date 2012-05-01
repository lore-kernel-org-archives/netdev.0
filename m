From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pch_gbe: reprogram multicast address register
 on reset
Date: Mon, 30 Apr 2012 21:47:27 -0400 (EDT)
Message-ID: <20120430.214727.2237869140591442277.davem@davemloft.net>
References: <1335592421-31406-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	tshimizu818@gmail.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757912Ab2EABrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:47:31 -0400
In-Reply-To: <1335592421-31406-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Sat, 28 Apr 2012 13:53:41 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> The reset logic after a Rx FIFO overrun will clear the programmed
> multicast addresses. This patch fixes the issue by reprogramming the
> registers after the reset.
> 
> The commit eefc48b tried to fix this problem, but it introduces
> unnecessary codes. In fact, all multicast addresses have been saved
> in netdev->mc, So we can call pch_gbe_set_multi() directly after
> reset_hw and reset_rx.
> 
> This commit kills 50+ line codes
> 
> Cc: Richard Cochran <richardcochran@gmail.com>
> Cc: Takahiro Shimizu <tshimizu818@gmail.com>
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

Applied.
