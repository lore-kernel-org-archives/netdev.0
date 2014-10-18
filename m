From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix a potential use after free in ip6_offload.c
Date: Sat, 18 Oct 2014 13:07:41 -0400 (EDT)
Message-ID: <20141018.130741.562869495961086552.davem@davemloft.net>
References: <1413624462-13106-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbaJRRHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 13:07:42 -0400
In-Reply-To: <1413624462-13106-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Sat, 18 Oct 2014 17:27:42 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() maybe change skb->data and make opth pointer oboslete,
> so set the opth again
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
