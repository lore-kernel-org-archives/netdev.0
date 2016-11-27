From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: do not use priv->stats_lock in
 mlx4_en_auto_moderation()
Date: Sun, 27 Nov 2016 15:26:58 -0500 (EST)
Message-ID: <20161127.152658.2037380124287360695.davem@davemloft.net>
References: <1479923212.8455.515.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752541AbcK0U1A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 15:27:00 -0500
In-Reply-To: <1479923212.8455.515.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Nov 2016 09:46:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Per RX ring packets/bytes counters are not protected by global
> priv->stats_lock.
> 
> Better not confuse the reader, and use READ_ONCE() to show we read
> these counters without surrounding synchronization.
> 
> Interrupt moderation is best effort, and we do not really care of
> ultra precise counters.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
