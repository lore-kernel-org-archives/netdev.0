From: Tim Beale <Tim.Beale@alliedtelesis.co.nz>
Subject: RE: [PATCH] net: phy: Make sure PHY_RESUMING state change is always
 processed
Date: Mon, 18 May 2015 03:38:28 +0000
Message-ID: <a7066e20b45441a2bebdccffe7237983@svr-chch-ex1.atlnz.lc>
References: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>,<5556645D.4050202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:48309 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbbERDig convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:38:36 -0400
In-Reply-To: <5556645D.4050202@gmail.com>
Content-Language: en-NZ
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> There seems no point for phy_start_aneg() to make the PHY_RESUMING -->
>> PHY_AN transition, as the state machine will do this anyway. I'm not sure
>> about the case where autoneg is disabled, as my patch will change
>> behaviour so that the PHY goes to PHY_NOLINK instead of PHY_FORCING. An
>> alternative solution would be to move the phy_config_interrupt() and
>> phy_resume() work out of the state machine and into phy_start().

> Could you prepare a patch which does that? I do not have a setup where
> the PHY IRQ is a dedicated interrupt line, but I might be able to test
> something with a hack.

Hi Florian,

I'll send another patch to the list that implements the solution in an 
alternative way (moving the phy_config_interrupt()/phy_resume() work into
phy_start()). Have a look and see what you think.

Let me know if you need anything else.

Thanks,
Tim