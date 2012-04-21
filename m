From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: allow better page reuse in splice(sock
 -> pipe)
Date: Sat, 21 Apr 2012 16:31:42 -0400 (EDT)
Message-ID: <20120421.163142.1578808000662148300.davem@davemloft.net>
References: <1334864297.2395.220.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab2DUUbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 16:31:45 -0400
In-Reply-To: <1334864297.2395.220.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Apr 2012 21:38:17 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> splice() from socket to pipe needs linear_to_page() helper to transfert
> skb header to part of page.
> 
> We can reset the offset in the current sk->sk_sndmsg_page if we are the
> last user of the page.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
