From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [RFC] net: phy: phy drivers should not set
 SUPPORTED_Pause or SUPPORTED_Asym_Pause
Date: Tue, 1 Nov 2016 13:45:04 -0500
Message-ID: <5818E2B0.80902@codeaurora.org>
References: <1478020715-25578-1-git-send-email-timur@codeaurora.org>
 <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42258 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbcKASpG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:45:06 -0400
In-Reply-To: <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> So in premise, this is good, and is exactly what I have in mind for the
> series that I am cooking, but if we apply this alone, without a change
> in drivers/net/phy/phy.c which adds SUPPORTED_Pause |
> SUPPORTED_AsymPause to phydev->features, we are basically breaking the
> Ethernet MAC drivers that don't explicitly override phydev->features and
> yet rely on that to get flow control to work.

That's what I figured, but I wasn't sure how to handle that.  However, 
isn't the ability to pass pause frames a feature that some PHYs do not 
have?  That is, does every PHY support bits 10 and 11 in register 4?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
