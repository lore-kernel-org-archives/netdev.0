From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/6] net: phy: hook up clause 45 autonegotiation restart
Date: Mon, 5 Jun 2017 09:30:50 -0700
Message-ID: <2131d910-7cbd-012d-1b83-c892315b06ef@gmail.com>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
 <E1dHq68-0005Wy-Na@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36782 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753690AbdFEQax (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 12:30:53 -0400
Received: by mail-qt0-f196.google.com with SMTP id s33so9753549qtg.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 09:30:52 -0700 (PDT)
In-Reply-To: <E1dHq68-0005Wy-Na@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2017 04:23 AM, Russell King wrote:
> genphy_restart_aneg() can only restart autonegotiation on clause 22
> PHYs.  Add a phy_restart_aneg() function which selects between the
> clause 22 and clause 45 restart functionality depending on the PHY
> type and whether the Clause 45 PHY supports the Clause 22 register set.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
