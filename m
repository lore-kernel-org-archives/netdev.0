From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] ipv6: rework the lock in
 addrconf_permanent_addr
Date: Thu, 17 Mar 2016 21:03:59 -0400 (EDT)
Message-ID: <20160317.210359.537174751019074848.davem@davemloft.net>
References: <1458185955-7173-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbcCRBEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 21:04:04 -0400
In-Reply-To: <1458185955-7173-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 17 Mar 2016 11:39:15 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 1. nothing of idev is changed, so read lock is enough
> 2. ifp is changed, so used ifp->lock or cmpxchg to protect it
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Sorry this simplification is not appropriate for net-next at this
time, as it is closed.

Please resubmit this at a later date, thanks.
