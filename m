From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: release skb->dst in sock_queue_rcv_skb()
Date: Tue, 25 Nov 2008 16:23:03 -0800 (PST)
Message-ID: <20081125.162303.68359899.davem@davemloft.net>
References: <492B8274.6080609@cosmosbay.com>
	<20081124.210038.90767194.davem@davemloft.net>
	<492C919E.3050108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50899
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752362AbYKZAXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 19:23:03 -0500
In-Reply-To: <492C919E.3050108@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 26 Nov 2008 01:00:30 +0100

> Hum... for a tcp connection, dst refcount should already be pinned
> by a sk->sk_dst_cache. Maybe test refcount value, and if this value
> is > 1, dont take a reference. (given rcu_read_lock() is done before
> calling ip_rcv_finish())

Input route is different from output route.  sk->sk_dst_cache holds
the output route.  So I can't see how this can help here.


