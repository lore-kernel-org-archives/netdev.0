From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: qcom/emac: claim the irq only when the device is
 opened
Date: Fri, 20 Jan 2017 15:36:23 -0600
Message-ID: <91ecc8ae-2ee4-5b08-ea04-b65890d3fa0e@codeaurora.org>
References: <1484775745-14050-1-git-send-email-timur@codeaurora.org>
 <c86ba3d4-8393-f88d-2414-9295feb6d661@gmx.de>
 <0b4a0259-f281-9b25-ef63-a09ef6725746@codeaurora.org>
 <4025bb82-bc41-abfd-1481-5e66abc25c65@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:54360 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbdATVgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 16:36:25 -0500
In-Reply-To: <4025bb82-bc41-abfd-1481-5e66abc25c65@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2017 03:31 PM, Lino Sanfilippo wrote:
>
> In emac_mac_down() however we need synchronize_irq(), since it ensures
> that the irq
> handler is not running any more when it (synchronize_irq) returns.

So in general, if a driver disables a interrupt but does not free it, it 
should call synchronize_irq()?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
