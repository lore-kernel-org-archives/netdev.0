From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] cpsw: ethtool: add support for getting/setting EEE
 registers
Date: Thu, 24 Nov 2016 16:38:09 +0100
Message-ID: <20161124153809.GA20455@lunn.ch>
References: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com>
 <93e0bd06-3171-e12b-b763-1e2895a463f8@gmail.com>
 <CAGm1_ksC_6afhzK39uVTSk2PoC9CrR4Fow89YCZfihS2f6wzOw@mail.gmail.com>
 <c91dcd74-3983-3ab6-91f6-3657b1e601af@gmail.com>
 <CAGm1_ktuAbt0pr_NJu2GLDOavFV_bvMBmH5RvDxr5AyXvfwB3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>,
        Rami Rosen <roszenrami@gmail.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54342 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966777AbcKXPiL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 10:38:11 -0500
Content-Disposition: inline
In-Reply-To: <CAGm1_ktuAbt0pr_NJu2GLDOavFV_bvMBmH5RvDxr5AyXvfwB3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> As for enabling advertising and correct working of cpsw do you mean it
> would be better to disable EEE in any PHY on cpsw initialization as
> long as cpsw doesn't provide support for EEE?
> 
> We observe some strange behavior with our gigabit PHYs and a link
> partner in a EEE-capable unmanaged NetGear switch. Disabling
> advertising seems to help. Though we're still investigating the issue.

Hi Florian

Am i right in saying, a PHY should not advertise EEE until the MAC
driver calls phy_init_eee(), indicating the MAC supports EEE?

If so, it looks like we need to change a few of the PHY drivers, in
particular, the bcm-*.c.

    Andrew
