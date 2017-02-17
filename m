From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bgmac: store MAC address directly in
 netdev->dev_addr
Date: Fri, 17 Feb 2017 13:03:51 -0500 (EST)
Message-ID: <20170217.130351.2166612074816910690.davem@davemloft.net>
References: <20170216141119.18505-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rafal@milecki.pl, f.fainelli@gmail.com,
        jon.mason@broadcom.com, arnd@arndb.de
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934053AbdBQSDx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 13:03:53 -0500
In-Reply-To: <20170216141119.18505-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 16 Feb 2017 15:11:19 +0100

> After commit 34a5102c3235 ("net: bgmac: allocate struct bgmac just once
> & don't copy it") the mac_addr member of struct bgmac is no longer
> necessary to pass the MAC address to bgmac_enet_probe(). Instead it can
> directly be stored in netdev->dev_addr.
> 
> Also use eth_hw_addr_random() instead of eth_random_addr() in case a
> random MAC is nedded. This will make sure netdev->addr_assign_type will
> be properly set.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next, thank you.
