From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 08:03:18 -0500
Message-ID: <5800D796.1030602@codeaurora.org>
References: <5800159B.3080708@codeaurora.org> <20161014040641.GE5822@lunn.ch>
 <5800C3C7.60705@codeaurora.org> <20161014120624.GG5822@lunn.ch>
 <5800D214.70808@codeaurora.org> <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org> <20161014125736.GK5822@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46550 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753108AbcJNNDU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 09:03:20 -0400
In-Reply-To: <20161014125736.GK5822@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn wrote:
> Have you tried using the ethernet-phy-id device tree property? It
> looks like that will allow you to skip get_phy_device and just create
> the phy device. You can then bring the phy out of sleep in the probe
> function?

The problem I'm experiencing is with ACPI, so I can't use any of the 
fancy of_ apis like of_get_phy_id().  But I'll look into it.

Is it possible that at803x_suspend() is too aggressive?  That's it's 
effectively disabling the phy?  While the phy is suspended, should it 
still respond to MII_PHYSID1 and MII_PHYSID2 requests?

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
