From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vxlan: fix a free after use
Date: Fri, 17 Oct 2014 16:24:17 -0400 (EDT)
Message-ID: <20141017.162417.639967647442435055.davem@davemloft.net>
References: <1413525976-2624-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868AbaJQUYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 16:24:18 -0400
In-Reply-To: <1413525976-2624-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 17 Oct 2014 14:06:16 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull maybe change skb->data and make eth pointer oboslete,
> so eth needs to reload
> 
> Fixes: 91269e390d062 ("vxlan: using pskb_may_pull as early as possible")
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
