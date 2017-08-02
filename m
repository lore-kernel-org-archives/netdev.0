From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Tue, 1 Aug 2017 22:22:53 -0500
Message-ID: <dd138150-a16f-699f-d1a4-2101de4a5832@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <20170801231554.GA8415@lunn.ch>
 <6a6ac2c1-eb78-d7fd-5721-49dd6a550913@codeaurora.org>
 <20170802025847.GB8415@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37766 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751773AbdHBDW5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 23:22:57 -0400
In-Reply-To: <20170802025847.GB8415@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/1/17 9:58 PM, Andrew Lunn wrote:
>   The PHY does not participate directly in flow control/pause frames except by
>   making sure that the SUPPORTED_Pause and SUPPORTED_AsymPause bits are set in
>   MII_ADVERTISE to indicate towards the link partner that the Ethernet MAC
>   controller supports such a thing. Since flow control/pause frames generation
>   involves the Ethernet MAC driver, it is recommended that this driver takes care
>   of properly indicating advertisement and support for such features by setting
>   the SUPPORTED_Pause and SUPPORTED_AsymPause bits accordingly. This can be done
>   either before or after phy_connect() and/or as a result of implementing the
>   ethtool::set_pauseparam feature.
> 
> So just check if the MAC driver is setting SUPPORTED_Pause and
> SUPPORTED_AsymPause.

I think this was covered in this thread: 
http://www.spinics.net/lists/netdev/msg408978.html

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
