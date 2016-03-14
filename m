From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] ipv6: replace write lock with read lock in
 addrconf_permanent_addr
Date: Mon, 14 Mar 2016 12:25:34 -0400 (EDT)
Message-ID: <20160314.122534.345751583747280951.davem@davemloft.net>
References: <1457948108-24837-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbcCNQZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 12:25:37 -0400
In-Reply-To: <1457948108-24837-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 14 Mar 2016 17:35:08 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> nothing of idev is changed, so read lock is enough
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

We need it for the modifications made by fixup_permanent_addr().
