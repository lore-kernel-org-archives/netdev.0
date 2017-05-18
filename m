From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sh_eth: Use platform device for printing before
 register_netdev()
Date: Thu, 18 May 2017 11:21:21 -0400 (EDT)
Message-ID: <20170518.112121.1062259248978837483.davem@davemloft.net>
References: <1495112495-25086-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com,
        laurent.pinchart+renesas@ideasonboard.com, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932767AbdERPVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:21:24 -0400
In-Reply-To: <1495112495-25086-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Thu, 18 May 2017 15:01:34 +0200

> The MDIO initialization failure message is printed using the network
> device, before it has been registered, leading to:
> 
>      (null): failed to initialise MDIO
> 
> Use the platform device instead to fix this:
> 
>     sh-eth ee700000.ethernet: failed to initialise MDIO
> 
> Fixes: daacf03f0bbfefee ("sh_eth: Register MDIO bus before registering the network device")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Applied.
