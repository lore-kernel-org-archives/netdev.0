From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: Update RFS target at poll for tcp/udp
Date: Fri, 31 May 2013 16:25:03 -0700 (PDT)
Message-ID: <20130531.162503.1098660752558653990.davem@davemloft.net>
References: <1370042138.24311.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, majnemer@google.com, pjt@google.com,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757517Ab3EaXZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 19:25:04 -0400
In-Reply-To: <1370042138.24311.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 31 May 2013 16:15:38 -0700

> From: David Majnemer <majnemer@google.com>
> 
> The current state of affairs is that read()/write() will setup
> RFS (Receive Flow Steering) for internet protocol sockets while
> poll()/epoll() does not.
> 
> When poll() gets called with a TCP or UDP socket, we should update
> the flow target.
> 
> This permits to RFS (if enabled) to select the appropriate CPU for
> following incoming packets.
> 
> Note: Only connected UDP sockets can benefit from RFS.
> 
> Signed-off-by: David Majnemer <majnemer@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
