From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 6/6] net: phy: add Marvell Alaska X 88X3310 10Gigabit PHY
 support
Date: Mon, 5 Jun 2017 11:21:27 -0700
Message-ID: <3386f7e9-b12a-fc8a-2b83-d94c4984d990@gmail.com>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
 <E1dHq6O-0005XL-2m@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35412 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdFESVa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 14:21:30 -0400
Received: by mail-qt0-f195.google.com with SMTP id x58so10485114qtc.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 11:21:30 -0700 (PDT)
In-Reply-To: <E1dHq6O-0005XL-2m@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2017 04:23 AM, Russell King wrote:
> Add phylib support for the Marvell Alaska X 10 Gigabit PHY (MV88X3310).
> This phy is able to operate at 10G, 1G, 100M and 10M speeds, and only
> supports Clause 45 accesses.
> 
> The PHY appears (based on the vendor IDs) to be two different vendors
> IP, with each devad containing several instances.
> 
> This PHY driver has only been tested with the RJ45 copper port, fiber
> port and a Marvell Armada 8040-based ethernet interface.
> 
> It should be noted that to use the full range of speeds, MAC drivers
> need to also reconfigure the link mode as per phydev->interface, since
> the PHY automatically changes its interface mode depending on the
> negotiated speed.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
