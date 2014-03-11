From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: ip6_forward: perform skb->pkt_type
 check at the beginning
Date: Mon, 10 Mar 2014 21:49:01 -0400 (EDT)
Message-ID: <20140310.214901.1619965966009209363.davem@davemloft.net>
References: <1394428220-9955-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbaCKBtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 21:49:03 -0400
In-Reply-To: <1394428220-9955-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 10 Mar 2014 13:10:20 +0800

> From: Li RongQing <roy.qing.li@gmail.com> 
> 
> Packets which have L2 address different from ours should be
> already filtered before entering into ip6_forward().
> 
> Perform that check at the beginning to avoid processing such packets.
> And use unlikely to optimise.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Based upon Eric's feedback for your ipv4 patch, please remove
the unlikely() for this ipv6 one.
