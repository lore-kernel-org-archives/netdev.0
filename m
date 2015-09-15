From: Peter Korsgaard <peter@korsgaard.com>
Subject: Re: DSA: phy polling
Date: Tue, 15 Sep 2015 08:32:38 +0200
Message-ID: <87y4g8xke1.fsf@dell.be.48ers.dk>
References: <20150914104254.GI21084@n2100.arm.linux.org.uk>
	<55F703D7.1070707@gmail.com>
	<20150914182314.GP21084@n2100.arm.linux.org.uk>
	<55F74D2A.8010104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:32999 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbbIOGcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 02:32:42 -0400
Received: by wiclk2 with SMTP id lk2so13613668wic.0
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 23:32:41 -0700 (PDT)
In-Reply-To: <55F74D2A.8010104@gmail.com> (Florian Fainelli's message of "Mon,
	14 Sep 2015 15:41:46 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Florian" == Florian Fainelli <f.fainelli@gmail.com> writes:

Hi,

 >> Does the Marvell phy have such a register?  Looking at the register
 >> dump and plugging/unplugging cables seems not to show a register
 >> reporting whether any particular interface has changed state, and
 >> I haven't noticed there being any combined register in anything I've
 >> seen on these switches.

 > It seemed to me like the PPU was meant to provide that, but I cannot
 > find any "summary" register which would give you such a status, must
 > have conflated that with what Broadcom switches support.

It's been some years, but I think the PPU was just to automatically
configure the switch MACs to to match the phy autonegotiation results.

I also don't see any summery register though.

-- 
Bye, Peter Korsgaard
