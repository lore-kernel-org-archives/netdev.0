From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Tue, 1 Aug 2017 19:56:31 -0500
Message-ID: <6a6ac2c1-eb78-d7fd-5721-49dd6a550913@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <20170801231554.GA8415@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56514 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdHBA4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 20:56:33 -0400
In-Reply-To: <20170801231554.GA8415@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/1/17 6:15 PM, Andrew Lunn wrote:
> Pause frames are something you can auto-negotiate at the PHY
> level. Should you also be clearing some bits in the phydev, so the
> peer knows pause frames are not supported?

When pause frame autonegotiation is enabled in the driver, that only 
means that the driver looks at what the PHY has autonegotiated, and then 
configures the MAC to match that.

The driver doesn't touch the PHY at all.  It leaves all that to phylib.

Now if autonegotiation is disabled in the driver, then it just 
hard-codes those TX/RX settings in the driver.  Are you saying I should 
program the PHY at the point to disable autonegotiation on the PHY 
level?  If so, then I don't know how to do that.  I just assumed that 
the MAC never tells the PHY what to do.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
