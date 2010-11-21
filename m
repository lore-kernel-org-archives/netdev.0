From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net: allow GFP_HIGHMEM in __vmalloc()
Date: Sun, 21 Nov 2010 10:04:20 -0800 (PST)
Message-ID: <20101121.100420.112583140.davem@davemloft.net>
References: <1290275195.2756.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45196
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755107Ab0KUSDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 13:03:55 -0500
In-Reply-To: <1290275195.2756.94.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 20 Nov 2010 18:46:35 +0100

> We forgot to use __GFP_HIGHMEM in several __vmalloc() calls.
> 
> In ceph, add the missing flag.
> 
> In fib_trie.c, xfrm_hash.c and request_sock.c, using vzalloc() is
> cleaner and allows using HIGHMEM pages as well.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
