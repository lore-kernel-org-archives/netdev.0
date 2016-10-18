From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: Need help with mdiobus_register and phy
Date: Tue, 18 Oct 2016 12:31:42 +0200
Message-ID: <21038884-a76e-1647-9194-be510a2f9da4@neratec.com>
References: <5800D214.70808@codeaurora.org> <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org> <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org> <20161014131852.GM5822@lunn.ch>
 <58010E79.2030607@codeaurora.org> <20161014172514.GA23455@lunn.ch>
 <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
 <58023F90.5070302@codeaurora.org> <20161015180219.GB6918@lunn.ch>
 <58027540.6080604@codeaurora.org>
 <7dced72e-c441-06d1-161d-3bccad34f2cd@neratec.com>
 <58053A33.4030108@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:3014 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753306AbcJRKbq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 06:31:46 -0400
In-Reply-To: <58053A33.4030108@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2016 10:53 PM, Timur Tabi wrote:
> Zefir Kurtisi wrote:
>> Anyway, since the SGMII reset is required, instead of reverting the patch in full
>> I suggest to move the SGMII power down from at803x_suspend() and do a SerDes power
>> cycle in at803x_resume(). Could you please test if the patch below fixes the
>> problem?
> 
> I have never seen the original problem that you noticed.  When I use the generic
> phy driver instead of the at803x driver, everything works great for me.  Perhaps
> the problem that you noticed only occurs with the Gianfar NIC?
> 
You mean it works for you in SGMII mode without glitches? Then it might in fact be
an unfortunate rare or unique combination that we chose.

> Anyway, I tested the change you suggested, and it fixes the problem for me.  I
> moved the power-down code to before the power-up code.  But like I said, since I
> never experienced the original problem, I don't know if that works for you.
> 
> I suggest you make the changes in the driver yourself and test it, and then I will
> test whether that patch also works for me.
> 

I'd need some time to get that tested, and since our device might be the only one
requiring the fix, I am fine with keeping the patch private. Feel free to revert
it, if required, I'll provide a revised one.


Thanks
Zefir
