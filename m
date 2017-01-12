From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: core: Make netif_wake_subqueue a wrapper
Date: Thu, 12 Jan 2017 09:18:27 -0500 (EST)
Message-ID: <20170112.091827.2230094704804198069.davem@davemloft.net>
References: <20170112051302.1064-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdALOS2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:18:28 -0500
In-Reply-To: <20170112051302.1064-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 11 Jan 2017 21:13:02 -0800

> netif_wake_subqueue() is duplicating the same thing that netif_tx_wake_queue()
> does, so make it call it directly after looking up the queue from the index.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Looks good, applied.
