From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 07/13] net: phy: add I2C mdio bus
Date: Wed, 26 Jul 2017 15:35:11 -0700
Message-ID: <9e0332af-cc08-1452-2fd7-aaa112d85bf4@gmail.com>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <E1da0QW-0007Lg-BH@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38046 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751022AbdGZWfQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 18:35:16 -0400
Received: by mail-wr0-f194.google.com with SMTP id g32so5835881wrd.5
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 15:35:15 -0700 (PDT)
In-Reply-To: <E1da0QW-0007Lg-BH@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2017 07:03 AM, Russell King wrote:
> Add an I2C MDIO bus bridge library, to allow phylib to access PHYs which
> are connected to an I2C bus instead of the more conventional MDIO bus.
> Such PHYs can be found in SFP adapters and SFF modules.
> 
> Since PHYs appear at I2C bus address 0x40..0x5f, and 0x50/0x51 are
> reserved for SFP EEPROMs/diagnostics, we must not allow the MDIO bus
> to access these I2C addresses.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
