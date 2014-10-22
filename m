From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] xfrm: fix a potential use after free in
 xfrm4_policy.c
Date: Tue, 21 Oct 2014 21:42:52 -0400 (EDT)
Message-ID: <20141021.214252.1991608537444325198.davem@davemloft.net>
References: <1413794954-16967-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810AbaJVBmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 21:42:53 -0400
In-Reply-To: <1413794954-16967-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 20 Oct 2014 16:49:13 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() maybe change skb->data and make xprth pointer oboslete,
> so recompute the xprth
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Please don't use macros that hide uses of local variables.

That is almost as bad as hiding control flow inside of
a macro.
