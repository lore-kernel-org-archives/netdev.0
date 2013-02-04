From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: remove redundant check for timer
 pending state before del_timer
Date: Mon, 04 Feb 2013 13:33:44 -0500 (EST)
Message-ID: <20130204.133344.1223239189712398536.davem@davemloft.net>
References: <1359959577-31525-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754984Ab3BDSdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 13:33:47 -0500
In-Reply-To: <1359959577-31525-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 4 Feb 2013 14:32:57 +0800

> As in del_timer() there has already placed a timer_pending() function
> to check whether the timer to be deleted is pending or not, it's
> unnecessary to check timer pending state again before del_timer() is
> called.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Eric Dumazet <edumazet@google.com>

Applied.
