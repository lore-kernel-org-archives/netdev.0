From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 1/3] lan78xx: Fix for eeprom read/write when device
 autosuspend
Date: Thu, 7 Sep 2017 16:04:26 +0200
Message-ID: <20170907140426.GI11248@lunn.ch>
References: <CE371C1263339941885964188A0225FA333A6B@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59585 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932178AbdIGOE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 10:04:29 -0400
Content-Disposition: inline
In-Reply-To: <CE371C1263339941885964188A0225FA333A6B@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 07, 2017 at 07:11:06AM +0000, Nisar.Sayed@microchip.com wrote:
> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Fix for eeprom read/write when device autosuspend

So this is a fix? And you said [PATCH net 1/3], meaning it is supposed
to go into stable? You should try to add a fixes tag. Something like:

Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")

       Andrew
