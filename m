From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4/5] net: phy: add XAUI and 10GBASE-KR PHY connection
 types
Date: Thu, 1 Jun 2017 09:56:48 -0700
Message-ID: <fb1a81e0-b5b9-80e4-7852-cc65a574b9e9@gmail.com>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJX-00043v-3M@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35857 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdFAQ46 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 12:56:58 -0400
In-Reply-To: <E1dGNJX-00043v-3M@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2017 03:26 AM, Russell King wrote:
> XAUI allows XGMII to reach an extended distance by using a XGXS layer at
> each end of the MAC to PHY link, operating over four Serdes lanes.
> 
> 10GBASE-KR is a single lane Serdes backplane ethernet connection method
> with autonegotiation on the link.  Some PHYs use this to connect to the
> ethernet interface at 10G speeds, switching to other connection types
> when utilising slower speeds.
> 
> 10GBASE-KR is also used for XFI and SFI to connect to XFP and SFP fiber
> modules.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

This looks good, but you also need to update
Documentation/ABI/testing/sysfs-class-net-phydev since we report
phy_interface from sysfs.

With that fixed:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
