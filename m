From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Tue, 26 Apr 2016 10:23:02 -0700
Message-ID: <571FA3F6.7000903@gmail.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <1461230323-27891-2-git-send-email-pramod.kumar@broadcom.com>
 <20160425205650.GA31129@lunn.ch>
 <666dffb41a922b0c8638f2f002a2de08@mail.gmail.com>
 <20160426121335.GC11668@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Suzuki K Poulose <suzuki.poulose@arm.com>,
	netdev@vger.kernel.org, Punit Agrawal <punit.agrawal@arm.com>,
	linux-kernel@vger.kernel.org,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	linux-arm-kernel@lists.infradead.org,
	Anup Patel <anup.patel@broadcom.com>
To: Andrew Lunn <andrew@lunn.ch>,
	Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34975 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbcDZRZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 13:25:22 -0400
In-Reply-To: <20160426121335.GC11668@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/04/16 05:13, Andrew Lunn wrote:
>> 4. Apart from these, by using MDIO mux framework we are making our
>> non-ethernet PHYs dependent on Linux network drivers which is not
>> acceptable. What if some product line does not need network subsystem at
>> all?
> 
> This is your only valid point. However, does Broadcom have a product
> line which does not include networking? Is not Broadcom a network SoC
> vendor?

But even with that, there is no reason why we could not decouple the
PHYLIB MDIO framework from PHYLIB and make it available as a more
standalone subsystem which can be utilized when you have a mix of MDIO
devices like here.

I am not clear on how common a shared MDIO bus is on other SoCs, but the
other Broadcom SoCs I am familiar with have dedicated MDIO buses
instances per type of PHY (PCIe, BUSB, Ethernet), thus making the split
a ton easier.
-- 
Florian
