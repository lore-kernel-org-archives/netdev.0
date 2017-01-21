From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] net: qcom/emac: claim the irq only when the device is
 opened
Date: Sat, 21 Jan 2017 03:14:23 +0100
Message-ID: <9793b888-8808-de39-83f1-4c726456aa2c@gmx.de>
References: <1484775745-14050-1-git-send-email-timur@codeaurora.org>
 <c86ba3d4-8393-f88d-2414-9295feb6d661@gmx.de>
 <0b4a0259-f281-9b25-ef63-a09ef6725746@codeaurora.org>
 <4025bb82-bc41-abfd-1481-5e66abc25c65@gmx.de>
 <91ecc8ae-2ee4-5b08-ea04-b65890d3fa0e@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:55419 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751028AbdAUCQL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 21:16:11 -0500
In-Reply-To: <91ecc8ae-2ee4-5b08-ea04-b65890d3fa0e@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 20.01.2017 22:36, Timur Tabi wrote:
> On 01/20/2017 03:31 PM, Lino Sanfilippo wrote:
>>
>> In emac_mac_down() however we need synchronize_irq(), since it ensures
>> that the irq
>> handler is not running any more when it (synchronize_irq) returns.
>
> So in general, if a driver disables a interrupt but does not free it, 
> it should call synchronize_irq()?
>

Yes, thats right.

Regards,
Lino
