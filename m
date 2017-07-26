From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 01/13] net: phy: allow settings table to support more
 than 32 link modes
Date: Wed, 26 Jul 2017 15:36:30 -0700
Message-ID: <a0cd74d4-7257-a96e-f294-4c3c1c8cf8f0@gmail.com>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <E1da0Q1-0007Ko-Fu@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34574 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdGZWgf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 18:36:35 -0400
Received: by mail-wr0-f195.google.com with SMTP id o33so15599159wrb.1
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 15:36:35 -0700 (PDT)
In-Reply-To: <E1da0Q1-0007Ko-Fu@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2017 07:02 AM, Russell King wrote:
> Allow the phy settings table to support more than 32 link modes by
> switching to the ethtool link mode bit number representation, rather
> than storing the mask.  This will allow phylink and other ethtool
> code to share the settings table to look up settings.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
