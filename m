From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 0/2] phylib non-autoneg speed setting
Date: Fri, 7 Apr 2017 13:51:29 -0700
Message-ID: <91f3a6de-6a21-1d76-d6d3-74f952d8e338@gmail.com>
References: <20170406100033.GA24671@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34001 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751174AbdDGUvd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 16:51:33 -0400
Received: by mail-qk0-f194.google.com with SMTP id p68so11715353qke.1
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 13:51:33 -0700 (PDT)
In-Reply-To: <20170406100033.GA24671@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/06/2017 03:00 AM, Russell King - ARM Linux wrote:
> This set of two patches fixes and cleans up the phylib code associated
> with selecting the fixed mode.
> 
> phylib currently assumes that all PHYs will support the 10baseT/Half mode
> of operation irrespective of the supported bitmask, because of the way
> phy_find_valid() and phy_find_setting() operate.
> 
> This series resolves that by reimplementing the table lookup, filtering
> out all unsupported modes.  This results in an unsupported speed setting
> always choosing one of the speeds that are supported by the PHY.  Full
> details are in the patch commit log.
> 
> The second patch cleans up the loop in phy_supported_speeds().

This looks totally fine to me, do you mind resubmitting as non RFC?

> 
>  drivers/net/phy/phy.c | 119 ++++++++++++++++++++++++++++----------------------
>  1 file changed, 68 insertions(+), 51 deletions(-)
> 
> v1->v2: fixed 0-day build errors
> 

-- 
Florian
