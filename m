From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: systemport: Be drop monitor friendly
Date: Thu, 24 Aug 2017 18:23:46 -0700 (PDT)
Message-ID: <20170824.182346.1025832510600253819.davem@davemloft.net>
References: <20170824222041.8377-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753962AbdHYBXr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:23:47 -0400
In-Reply-To: <20170824222041.8377-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 24 Aug 2017 15:20:41 -0700

> Utilize dev_consume_skb_any(cb->skb) in bcm_sysport_free_cb() which is
> used when a TX packet is completed, as well as when the RX ring is
> cleaned on shutdown. None of these two cases are packet drops, so be
> drop monitor friendly.
> 
> Suggested-by: Eric Dumazet <edumazet@gmail.com>
> Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
