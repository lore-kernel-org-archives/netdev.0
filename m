From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 21 Oct 2016 06:19:20 -0500
Message-ID: <5809F9B8.4010505@codeaurora.org>
References: <5800D214.70808@codeaurora.org> <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org> <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org> <20161014131852.GM5822@lunn.ch>
 <58010E79.2030607@codeaurora.org> <20161014172514.GA23455@lunn.ch>
 <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
 <58023F90.5070302@codeaurora.org> <20161015180219.GB6918@lunn.ch>
 <58027540.6080604@codeaurora.org>
 <7dced72e-c441-06d1-161d-3bccad34f2cd@neratec.com>
 <58053A33.4030108@codeaurora.org>
 <21038884-a76e-1647-9194-be510a2f9da4@neratec.com>
 <58061831.6080005@codeaurora.org>
 <dfff1abf-f506-bffa-8e09-edeebd753be5@neratec.com>
 <58076403.3060608@codeaurora.org>
 <bff7ab7f-93e4-8d78-ac73-e97d1832d155@neratec.com>
 <e4b86886-737a-0a1c-c95a-34b6b6373755@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33556 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754060AbcJULTX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 07:19:23 -0400
In-Reply-To: <e4b86886-737a-0a1c-c95a-34b6b6373755@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zefir Kurtisi wrote:
>> >Now the interesting (and new for me) part is: if I remove the at803x driver from
>> >the system and use the generic phy instead, the problem does not happen (or at
>> >least not while running for one full day). [...]
>> >
> Update: the failure also happened with genphy after running for another day.

I haven't had a chance to try to reproduce this failure, but to me this 
sounds like you have a problem with gianfar or your board, and not the 
at803x driver.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
