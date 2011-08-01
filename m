From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: avoid a dst_entry refcount change in
 ipv6_destopt_rcv()
Date: Mon, 01 Aug 2011 01:55:58 -0700 (PDT)
Message-ID: <20110801.015558.1067460554428695878.davem@davemloft.net>
References: <1311861635.2346.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab1HAIz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 04:55:59 -0400
In-Reply-To: <1311861635.2346.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Jul 2011 16:00:35 +0200

> ipv6_destopt_rcv() runs with rcu_read_lock(), so there is no need to
> take a temporay reference on dst_entry, even if skb is freed by
> ip6_parse_tlv()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Queued up for net-next
