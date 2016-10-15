From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Sat, 15 Oct 2016 13:28:16 -0500
Message-ID: <58027540.6080604@codeaurora.org>
References: <5800D214.70808@codeaurora.org> <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org> <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org> <20161014131852.GM5822@lunn.ch>
 <58010E79.2030607@codeaurora.org> <20161014172514.GA23455@lunn.ch>
 <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
 <58023F90.5070302@codeaurora.org> <20161015180219.GB6918@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, zefir.kurtisi@neratec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47233 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751392AbcJOS2b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 14:28:31 -0400
In-Reply-To: <20161015180219.GB6918@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn wrote:
> 1) Take the SerDes power down out of the suspend code for the at803x.
>
> 2) Assume MII_PHYID1/2 registers are not guaranteed to be available
> when the PHY is powered down. So get_phy_id should first read
> MII_BMCR. If it gets 0xffff, assume there is no PHY there. If the
> PDOWN bit is set, power up the PHY. Then reading the ID registers.

Before we take approach #1, I'd like to hear from the developer of that 
patch, Zefir.  According to him, that patch is necessary to fix a bug. 
I don't know if that bug exists only on his system, though.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
