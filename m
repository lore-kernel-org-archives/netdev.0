From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv6: rework the lock in addrconf_permanent_addr
Date: Fri, 01 Apr 2016 14:44:19 -0400 (EDT)
Message-ID: <20160401.144419.2268825550214210639.davem@davemloft.net>
References: <1459502818-24939-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbcDASoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 14:44:21 -0400
In-Reply-To: <1459502818-24939-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri,  1 Apr 2016 17:26:58 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 1. nothing of idev is changed, so read lock is enough
> 2. ifp is changed, so used ifp->lock or cmpxchg to protect it
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

You posted this patch twice and didn't post patch 2/2.

I'm tossing this from patchwork, please resubmit this
properly.
