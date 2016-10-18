From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Tue, 18 Oct 2016 07:40:17 -0500
Message-ID: <58061831.6080005@codeaurora.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45317 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754454AbcJRMkV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 08:40:21 -0400
In-Reply-To: <21038884-a76e-1647-9194-be510a2f9da4@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zefir Kurtisi wrote:

>> I have never seen the original problem that you noticed.  When I use the generic
>> phy driver instead of the at803x driver, everything works great for me.  Perhaps
>> the problem that you noticed only occurs with the Gianfar NIC?
>>
> You mean it works for you in SGMII mode without glitches?

That is correct.

> Then it might in fact be
> an unfortunate rare or unique combination that we chose.

That is what I expect.

> I'd need some time to get that tested, and since our device might be the only one
> requiring the fix, I am fine with keeping the patch private. Feel free to revert
> it, if required, I'll provide a revised one.

I'm in no hurry to get this fixed.  Do you need a couple weeks to run 
some tests?  It would be good to know for sure that your fix is needed 
only on your platform.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
