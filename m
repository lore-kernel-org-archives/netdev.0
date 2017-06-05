From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 5/6] net: phy: add XAUI and 10GBASE-KR PHY connection
 types
Date: Mon, 5 Jun 2017 09:24:35 -0700
Message-ID: <187fd723-55b0-3a94-1ad0-62b696eb4a90@gmail.com>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
 <E1dHq6I-0005XE-VR@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33007 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752850AbdFEQYi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 12:24:38 -0400
In-Reply-To: <E1dHq6I-0005XE-VR@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2017 04:23 AM, Russell King wrote:
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

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
