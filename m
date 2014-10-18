From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix a potential use after free
Date: Fri, 17 Oct 2014 23:46:19 -0400 (EDT)
Message-ID: <20141017.234619.2060902438346359137.davem@davemloft.net>
References: <1413536003-15646-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaJRDqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 23:46:21 -0400
In-Reply-To: <1413536003-15646-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 17 Oct 2014 16:53:23 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() maybe change skb->data and make eth pointer oboslete,
> so set eth after pskb_may_pull()
> 
> Fixes:3d7b46cd("ip_tunnel: push generic protocol handling to ip_tunnel module")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied and queued up for -stable.
