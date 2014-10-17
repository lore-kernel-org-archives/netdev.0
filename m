From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: fix a use after free
Date: Fri, 17 Oct 2014 16:23:08 -0400 (EDT)
Message-ID: <20141017.162308.1647313595498097545.davem@davemloft.net>
References: <1413525788-2272-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbaJQUXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 16:23:10 -0400
In-Reply-To: <1413525788-2272-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 17 Oct 2014 14:03:08 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() called by arphdr_ok can change skb->data, so put the arp
> setting after arphdr_ok to avoid the use the freed memory
> 
> Fixes: 0714812134d7d ("openvswitch: Eliminate memset() from flow_extract.")
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
