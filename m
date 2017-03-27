From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 3/3] net: phy: allow EEE with SGMII interface modes
Date: Mon, 27 Mar 2017 15:42:57 -0700
Message-ID: <3bcc3380-6e59-06e3-9ebd-5450e89c90a2@gmail.com>
References: <20170327095826.GA2310@n2100.armlinux.org.uk>
 <E1csRQT-0004rM-Tq@rmk-PC.armlinux.org.uk>
 <5d3c3ce0-fabc-6b96-c7e9-c2e46ffe4d23@gmail.com>
 <20170327170019.GR7909@n2100.armlinux.org.uk>
 <9f523664-9479-26ca-e3f7-95453ed03560@gmail.com>
 <20170327194747.GS7909@n2100.armlinux.org.uk>
 <705b10f9-6a0c-3a35-ddff-04b75c6f80ec@gmail.com>
 <20170327201529.GT7909@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34410 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752443AbdC0WnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 18:43:06 -0400
Received: by mail-qk0-f196.google.com with SMTP id 10so3757066qkh.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 15:43:05 -0700 (PDT)
In-Reply-To: <20170327201529.GT7909@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2017 01:15 PM, Russell King - ARM Linux wrote:
> Here's the revised patch as requested.
> 
> Thanks.
> 
> 8<===
> From: Russell King <rmk+kernel@armlinux.org.uk>
> Subject: [PATCH] net: phy: allow EEE with any interface mode
> 
> EEE is able to work in any PHY interface mode, there is nothing which
> fundamentally restricts it to only a few modes.  For example, EEE works
> in SGMII mode with the Marvell 88E1512.
> 
> Rather than just adding SGMII mode to the list, Florian suggests
> removing the list of interface modes entirely:
> 
>   It actually sounds like we should just kill the check entirely,
>   it does not appear that any of the interface mode would not
>   fundamentally be able to support EEE, because the "lowest" mode
>   we support is MII, and even there it's quite possible to support
>   EEE.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

I think David will require you to resubmit this as an entire patch
series and without an RFC tag. Do you want to hold off a bit to get
build coverage or go ahead and target net-next right away?

Thanks!
-- 
Florian
