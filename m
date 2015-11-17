From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net] net: use skb_clone to avoid alloc_pages failure.
Date: Tue, 17 Nov 2015 15:26:53 -0500 (EST)
Message-ID: <20151117.152653.2114816969798118712.davem@davemloft.net>
References: <1447764570-22647-1-git-send-email-martinbj2008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linggao.zjw@alibaba-inc.com
To: martinbj2008@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbbKQU0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 15:26:54 -0500
In-Reply-To: <1447764570-22647-1-git-send-email-martinbj2008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: martinbj2008@gmail.com
Date: Tue, 17 Nov 2015 20:49:30 +0800

> From: Martin Zhang <martinbj2008@gmail.com>
> 
> 1. new skb only need dst and ip address(v4 or v6).
> 2. skb_copy may need high order pages, which is very rare on long running server.
> 
> Signed-off-by: Junwei Zhang <linggao.zjw@alibaba-inc.com>
> Signed-off-by: Martin Zhang <martinbj2008@gmail.com>

Applied, thanks.
