From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: tcp: add rcu locking in tcp_v6_send_synack()
Date: Sun, 10 Jan 2016 22:59:53 -0500 (EST)
Message-ID: <20160110.225953.2100331012103485299.davem@davemloft.net>
References: <20160107153248.GA30472@codemonkey.org.uk>
	<1452181973.8255.213.camel@edumazet-glaptop2.roam.corp.google.com>
	<1452274551.8255.232.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757949AbcAKD7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 22:59:54 -0500
In-Reply-To: <1452274551.8255.232.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jan 2016 09:35:51 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When first SYNACK is sent, we already hold rcu_read_lock(), but this
> is not true if a SYNACK is retransmitted, as a timer (soft) interrupt
> does not hold rcu_read_lock()
> 
> Fixes: 45f6fad84cc30 ("ipv6: add complete rcu protection around np->opt")
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
