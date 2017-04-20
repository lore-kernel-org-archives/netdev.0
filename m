From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6] net: dsa: add SMSC/Microchip LAN9303 three port
 ethernet switch driver
Date: Thu, 20 Apr 2017 13:50:16 -0400 (EDT)
Message-ID: <20170420.135016.1255204402288999642.davem@davemloft.net>
References: <20170418084827.19613-1-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: jbe@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46114 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033125AbdDTRuS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 13:50:18 -0400
In-Reply-To: <20170418084827.19613-1-jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Juergen Borleis <jbe@pengutronix.de>
Date: Tue, 18 Apr 2017 10:48:23 +0200

> The LAN9303 is a three port 10/100 ethernet switch with integrated phys
> for the two external ethernet ports. The third port is an RMII/MII
> interface to a host master network interface (e.g. fixed link).
> 
> While the LAN9303 device itself supports offload packet processing, this
> driver does not make use of it yet. This driver just configures the device
> to provide two separate network interfaces (which is the default state of
> a DSA device).
> 
> Please note: the "MDIO managed mode" driver part isn't tested yet. I have
> used and tested the "I2C managed mode" only.
> 
> Changes in v6:
 ...

Series applied, thanks.
