From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix for ip_options_rcv_srr() daddr update.
Date: Wed, 09 Nov 2011 15:59:36 -0500 (EST)
Message-ID: <20111109.155936.1972852290616131285.davem@davemloft.net>
References: <4EBA2E30.8050102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513Ab1KIU7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 15:59:43 -0500
In-Reply-To: <4EBA2E30.8050102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Wed, 09 Nov 2011 15:39:28 +0800

> When opt->srr_is_hit is set skb_rtable(skb) has been updated for
> 'nexthop' and iph->daddr should always equals to skb_rtable->rt_dst
> holds, We need update iph->daddr either.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied, thank you.
