From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: introduce netdev_alloc_pcpu_stats() for
 drivers
Date: Fri, 14 Feb 2014 15:50:27 -0500 (EST)
Message-ID: <20140214.155027.85978951908473915.davem@davemloft.net>
References: <1392320788-17962-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbaBNUu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 15:50:29 -0500
In-Reply-To: <1392320788-17962-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 13 Feb 2014 11:46:28 -0800

> There are many drivers calling alloc_percpu() to allocate pcpu stats
> and then initializing ->syncp. So just introduce a helper function for them.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Looks good, applied, thanks.
