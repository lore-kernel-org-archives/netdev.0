From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 2/2] net_sched: fix another regression in
 cls_tcindex
Date: Sun, 28 Sep 2014 17:35:09 -0400 (EDT)
Message-ID: <20140928.173509.1456868163442906520.davem@davemloft.net>
References: <1411671965-18887-1-git-send-email-xiyou.wangcong@gmail.com>
	<1411671965-18887-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397AbaI1VfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 17:35:10 -0400
In-Reply-To: <1411671965-18887-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 25 Sep 2014 12:06:05 -0700

> Clearly the following change is not expected:
> 
> 	-       if (!cp.perfect && !cp.h)
> 	-               cp.alloc_hash = cp.hash;
> 	+       if (!cp->perfect && cp->h)
> 	+               cp->alloc_hash = cp->hash;
> 
> Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
