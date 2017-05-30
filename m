From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: fix marvell phy status reading
Date: Tue, 30 May 2017 09:46:21 -0700
Message-ID: <b2a497cd-7258-42df-0217-368d87b6ad16@gmail.com>
References: <E1dFixz-00062r-0n@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34534 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbdE3Qq0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 12:46:26 -0400
Received: by mail-wm0-f67.google.com with SMTP id d127so26249223wmf.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 09:46:26 -0700 (PDT)
In-Reply-To: <E1dFixz-00062r-0n@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2017 08:21 AM, Russell King wrote:
> The Marvell driver incorrectly provides phydev->lp_advertising as the
> logical and of the link partner's advert and our advert.  This is
> incorrect - this field is supposed to store the link parter's unmodified
> advertisment.
> 
> This allows ethtool to report the correct link partner auto-negotiation
> status.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Fixes: be937f1f89ca ("Marvell PHY m88e1111 driver fix")

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
