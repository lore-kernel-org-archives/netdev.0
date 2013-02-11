From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arp: fix possible crash in arp_rcv()
Date: Sun, 10 Feb 2013 20:40:54 -0500 (EST)
Message-ID: <20130210.204054.1090844260063864067.davem@davemloft.net>
References: <1360385301.6696.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779Ab3BKBk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 20:40:56 -0500
In-Reply-To: <1360385301.6696.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Feb 2013 20:48:21 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We should call skb_share_check() before pskb_may_pull(), or we
> can crash in pskb_expand_head()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

It's just a very odd set of combined circumstances we would
need for this to trigger and also cause a real problem of
any kind.

In any event, the fix is of course correct, and thus applied
to 'net'.  Thanks Eric!
