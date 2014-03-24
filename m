From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: fix the skb check in pkt_is_ns
Date: Mon, 24 Mar 2014 15:09:13 -0400 (EDT)
Message-ID: <20140324.150913.993091332318282510.davem@davemloft.net>
References: <1395406437-19834-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaCXTJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 15:09:15 -0400
In-Reply-To: <1395406437-19834-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 21 Mar 2014 20:53:57 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Neighbor Solicitation is ipv6 protocol, so we should check
> skb->protocol with ETH_P_IPV6
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied to 'net' and queued up for -stable.
