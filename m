From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: ip6_forward: perform skb->pkt_type
 check at the beginning
Date: Tue, 11 Mar 2014 00:38:01 -0400 (EDT)
Message-ID: <20140311.003801.264841440948786299.davem@davemloft.net>
References: <1394505608-7709-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbaCKEiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 00:38:06 -0400
In-Reply-To: <1394505608-7709-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue, 11 Mar 2014 10:40:08 +0800

> From: Li RongQing <roy.qing.li@gmail.com> 
> 
> Packets which have L2 address different from ours should be
> already filtered before entering into ip6_forward().
> 
> Perform that check at the beginning to avoid processing such packets.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
