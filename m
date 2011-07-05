From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 03:07:07 -0700 (PDT)
Message-ID: <20110705.030707.1975572017092435300.davem@davemloft.net>
References: <1309846875.2720.43.camel@edumazet-laptop>
	<20110705.004640.2280047904273455681.davem@davemloft.net>
	<1309859424.2271.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194Ab1GEKHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 06:07:14 -0400
In-Reply-To: <1309859424.2271.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Jul 2011 11:50:24 +0200

> You really have to call skb_get_rxhash() yourself to make sure rxhash is
> set (if not already done)
> 
> Just replace   skb->rxhash by skb_get_rxhash(skb)

Read v2 of my patch :-)
