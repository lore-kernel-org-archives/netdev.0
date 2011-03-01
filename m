From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] x25: remove the BKL
Date: Tue, 01 Mar 2011 15:16:22 -0800 (PST)
Message-ID: <20110301.151622.200374696.davem@davemloft.net>
References: <1299021191-17961-1-git-send-email-arnd@arndb.de>
	<1299021191-17961-6-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, andrew.hendry@gmail.com,
	linux-x25@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59553
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757353Ab1CAXPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:15:45 -0500
In-Reply-To: <1299021191-17961-6-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed,  2 Mar 2011 00:13:09 +0100

> This replaces all instances of lock_kernel in x25
> with lock_sock, taking care to release the socket
> lock around sleeping functions (sock_alloc_send_skb
> and skb_recv_datagram). It is not clear whether
> this is a correct solution, but it seem to be what
> other protocols do in the same situation.
> 
> Includes a fix suggested by Eric Dumazet.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: David S. Miller <davem@davemloft.net>
