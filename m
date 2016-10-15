From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Sat, 15 Oct 2016 09:39:12 -0500
Message-ID: <58023F90.5070302@codeaurora.org>
References: <20161014040641.GE5822@lunn.ch> <5800C3C7.60705@codeaurora.org>
 <20161014120624.GG5822@lunn.ch> <5800D214.70808@codeaurora.org>
 <20161014124928.GJ5822@lunn.ch> <5800D474.1030303@codeaurora.org>
 <20161014125736.GK5822@lunn.ch> <5800D796.1030602@codeaurora.org>
 <20161014131852.GM5822@lunn.ch> <58010E79.2030607@codeaurora.org>
 <20161014172514.GA23455@lunn.ch>
 <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47814 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754307AbcJOOjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 10:39:15 -0400
In-Reply-To: <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> After reading the spec again, it does not appear to me that a PHY
> with PDOWN set is guaranteed or even required to respond to other
> register reads such as MII_PHYID1/2, in which case we may have to
> implement a MDIO bus reset routine which clears PDOWN for all PHYs
> that we detect(ed), or as Andrew suggested, utilize the matching by
> compatible string with the PHY OUI in it.

The 8031 does respond normally when PDOWN is set.  However, the ID 
registers are not available when the SerDes bus is also powered down. 
I'll call this PDOWN+.  This is a special power-down sequence that the 
at803x driver does on suspend.  See my other email for details.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
