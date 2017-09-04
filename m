From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: loop: Do not unregister invalid fixed PHY
Date: Sun, 03 Sep 2017 20:19:23 -0700 (PDT)
Message-ID: <20170903.201923.1025438565183602962.davem@davemloft.net>
References: <20170902155645.19071-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753124AbdIDDTY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 23:19:24 -0400
In-Reply-To: <20170902155645.19071-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  2 Sep 2017 08:56:45 -0700

> During error injection it was possible to crash in dsa_loop_exit() because of
> an attempt to unregister an invalid PHY. We actually want to the driver probing
> in dsa_loop_init() even though fixed_phy_register() may return an error to
> exercise how DSA deals with such cases, but we should not be crashing during
> driver removal.
> 
> Fixes: 98cd1552ea27 ("net: dsa: Mock-up driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
