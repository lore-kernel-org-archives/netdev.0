From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: aquantia: remove function aq_ring_tx_deinit
Date: Mon, 20 Feb 2017 10:23:53 -0500 (EST)
Message-ID: <20170220.102353.2285049503711848984.davem@davemloft.net>
References: <1487417232-4103-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Simon.Edelhaus@aquantia.com, Pavel.Belous@aquantia.com,
        Alexey.Andriyanov@aquantia.com, netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38350 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753473AbdBTPYl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:24:41 -0500
In-Reply-To: <1487417232-4103-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Sat, 18 Feb 2017 12:27:12 +0100

> Both functions aq_ring_rx_deinit() and aq_ring_tx_clean() are almost
> identical aside from an additional check in the latter.
> Move that check from the function into its caller and replace
> aq_ring_rx_deinit() with aq_ring_rx_deinit().
> 
> By doing this also adjust the functions return value from int to void
> since it can never fail.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Applied.
