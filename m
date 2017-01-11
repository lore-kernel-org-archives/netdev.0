From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net/af_iucv: don't use paged skbs for TX on
 HiperSockets
Date: Tue, 10 Jan 2017 21:07:11 -0500 (EST)
Message-ID: <20170110.210711.1780886001866499809.davem@davemloft.net>
References: <20170110161034.82445-1-ubraun@linux.vnet.ibm.com>
        <20170110161034.82445-2-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935739AbdAKCHN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:07:13 -0500
In-Reply-To: <20170110161034.82445-2-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 10 Jan 2017 17:10:34 +0100

> From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
> 
> With commit e53743994e21
> ("af_iucv: use paged SKBs for big outbound messages"),
> we transmit paged skbs for both of AF_IUCV's transport modes
> (IUCV or HiperSockets).
> The qeth driver for Layer 3 HiperSockets currently doesn't
> support NETIF_F_SG, so these skbs would just be linearized again
> by the stack.
> Avoid that overhead by using paged skbs only for IUCV transport.
> 
> cc stable, since this also circumvents a significant skb leak when
> sending large messages (where the skb then needs to be linearized).
> 
> Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Cc: <stable@vger.kernel.org> # v4.8+
> Fixes: e53743994e21 ("af_iucv: use paged SKBs for big outbound messages")

Applied.
