From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] econet: fix locking
Date: Fri, 11 Jun 2010 18:39:24 -0700 (PDT)
Message-ID: <20100611.183924.45886086.davem@davemloft.net>
References: <1276137185.2475.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751532Ab0FLBjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 21:39:13 -0400
In-Reply-To: <1276137185.2475.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Jun 2010 04:33:05 +0200

> econet lacks proper locking. It holds econet_lock only when inserting or
> deleting an entry in econet_sklist, not during lookups.
> 
> - convert econet_lock from rwlock to spinlock
> 
> - use econet_lock in ec_listening_socket() lookup
> 
> - use appropriate sock_hold() / sock_put() to avoid corruptions.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
