From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 4/4] [net-next] net: qcom/emac: add an error interrupt
 handler for the sgmii
Date: Fri, 27 Jan 2017 17:21:19 -0600
Message-ID: <e44849a6-62ce-5d19-c622-20e7a5373f75@codeaurora.org>
References: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
 <1485557028-32510-5-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38784 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdA0XWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 18:22:03 -0500
In-Reply-To: <1485557028-32510-5-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2017 04:43 PM, Timur Tabi wrote:
> The SGMII (internal PHY) can report decode errors via an interrupt.  It
> can also report autonegotiation status changes, but we don't need to track
> those.  The SGMII can recover automatically from most decode errors, so
> we only reset the interface if we get multiple consecutive errors.
>
> It's possible for bogus decode errors to be reported while the link is
> being brought up.  The interrupt is registered when the interface is
> opened, and it's enabled after the link is up.
>
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Sorry, this particular patch wasn't meant to be in the patchset.  Please 
ignore it.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
