From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH] net: davinci_mdio: add GPIO reset logic
Date: Thu, 6 Apr 2017 19:48:50 +0300
Message-ID: <4611f957-4de2-ccf6-c9e6-1ace1f3f8ac3@ti.com>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <20170405150334.GI13449@lunn.ch>
 <485433e3-1a9f-71f6-afc9-88e646cf43d1@ti.com>
 <20170406120532.GC13219@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <tony@atomide.com>, <nsekhar@ti.com>,
        <jsarha@ti.com>, <netdev@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:53069 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932616AbdDFQtE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 12:49:04 -0400
In-Reply-To: <20170406120532.GC13219@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 06/04/17 15:05, Andrew Lunn wrote:
>>> Do you really need more than one GPIO? A single gpio would make all
>>> this code a lot simpler.
>>>
>>
>> Yes we need. Some of our boards have separate GPIO RESET lines for
>> different PHYs on the same MDIO bus.
> 
> If you have a one-to-one mapping of GPIO and PHY, you should really be
> modelling that differently. You want to be able to reset just a single
> PHY, i.e. make it part of the PHY driver, or maybe the PHY core.
> 
>      Andrew
> 


I'm not sure how it would be modelled. We have never had the need to reset
just one PHY on the MDIO bus.
Some boards have a single RESET line to multiple PHYs whereas others have individual
RESET lines. In all cases we just want to do the RESET once per boot.

cheers,
-roger
