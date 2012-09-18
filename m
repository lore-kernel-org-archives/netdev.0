From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: fix a rcu_read_lock() imbalance in make_blackhole
Date: Tue, 18 Sep 2012 16:30:55 -0400 (EDT)
Message-ID: <20120918.163055.1580882472532006729.davem@davemloft.net>
References: <1347957610-7422-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051Ab2IRUa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 16:30:57 -0400
In-Reply-To: <1347957610-7422-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue, 18 Sep 2012 16:40:10 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> if xfrm_policy_get_afinfo returns 0, it has already called rcu_read_unlock,
> xfrm_policy_put_afinfo should not be called again.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

This bug exists in the 'net' tree too, where this lock is a read lock.

I've applied this patch and adjusted the commit log text to accomodate
to difference.

Thanks.
