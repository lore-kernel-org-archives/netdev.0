From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Mon, 17 Oct 2016 15:53:07 -0500
Message-ID: <58053A33.4030108@codeaurora.org>
References: <5800D214.70808@codeaurora.org> <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org> <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org> <20161014131852.GM5822@lunn.ch>
 <58010E79.2030607@codeaurora.org> <20161014172514.GA23455@lunn.ch>
 <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
 <58023F90.5070302@codeaurora.org> <20161015180219.GB6918@lunn.ch>
 <58027540.6080604@codeaurora.org>
 <7dced72e-c441-06d1-161d-3bccad34f2cd@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33140 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933471AbcJQUxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 16:53:10 -0400
In-Reply-To: <7dced72e-c441-06d1-161d-3bccad34f2cd@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zefir Kurtisi wrote:
> Anyway, since the SGMII reset is required, instead of reverting the patch in full
> I suggest to move the SGMII power down from at803x_suspend() and do a SerDes power
> cycle in at803x_resume(). Could you please test if the patch below fixes the problem?

I have never seen the original problem that you noticed.  When I use the 
generic phy driver instead of the at803x driver, everything works great 
for me.  Perhaps the problem that you noticed only occurs with the 
Gianfar NIC?

Anyway, I tested the change you suggested, and it fixes the problem for 
me.  I moved the power-down code to before the power-up code.  But like 
I said, since I never experienced the original problem, I don't know if 
that works for you.

I suggest you make the changes in the driver yourself and test it, and 
then I will test whether that patch also works for me.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
