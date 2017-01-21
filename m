From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 6/8] net: phy: Marvell: Add mv88e6390 internal
 PHY
Date: Fri, 20 Jan 2017 16:04:24 -0800
Message-ID: <10330d5b-2fa6-e2a9-62f0-8c0d579c9ec0@gmail.com>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
 <1484955062-26718-7-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35279 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752229AbdAUAE0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:04:26 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so7980442pge.2
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 16:04:25 -0800 (PST)
In-Reply-To: <1484955062-26718-7-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2017 03:31 PM, Andrew Lunn wrote:
> The mv88e6390 Ethernet switch has internal PHYs. These PHYs don't have
> an model ID in the ID2 register. So the MDIO driver in the switch
> intercepts reads to this register, and returns the switch family ID.
> Extend the Marvell PHY driver by including this ID, and tread the PHY
> as a 88E1540.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
