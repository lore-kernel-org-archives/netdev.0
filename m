From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: replace write lock with read lock when get
 route info
Date: Thu, 13 Sep 2012 16:54:41 -0400 (EDT)
Message-ID: <20120913.165441.1070997286400575296.davem@davemloft.net>
References: <1347436741-344-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419Ab2IMUyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:54:43 -0400
In-Reply-To: <1347436741-344-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 12 Sep 2012 15:59:01 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> geting route info does not write rt->rt6i_table, so replace
> write lock with read lock
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

I'm surprised it's been like this for so long, but I can't find
any problems with your patch :-)

Applied to net-next, thanks.
