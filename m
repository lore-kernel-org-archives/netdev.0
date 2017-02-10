From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: cafe8df8b9bc clashes with DSA
Date: Fri, 10 Feb 2017 19:06:40 +0100
Message-ID: <20170210180640.GJ2103@lunn.ch>
References: <77093903.194093.1486748785802.JavaMail.zimbra@savoirfairelinux.com>
 <ccabc2d3-9589-f4f5-cdab-ee3ba40e8bc7@gmail.com>
 <87wpcyq6an.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, maowenan@huawei.com,
        netdev@vger.kernel.org
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34502 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752164AbdBJSk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 13:40:27 -0500
Content-Disposition: inline
In-Reply-To: <87wpcyq6an.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 12:55:44PM -0500, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
> > Fixed in the "net" tree with:
> >
> > 6d9f66ac7fec2a6ccd649e5909806dfe36f1fc25 ("net: phy: Fix PHY module
> > checks and NULL deref in phy_attach_direct()"), applies fine to net-next
> > as well.
> 
> Correct, this fixes my setup. Shouldn't this be submitted to net-next as
> well then?

Hi Vivien

David will at some point merge net into net-next.

Until then, you can work around the issue by enabling the PHY drivers
for you hardware. You are also likely to gain a few nice features,
like PHY interrupts rather than polling, maybe some temperature
sensors, PHY statistics, etc...

     Andrew
