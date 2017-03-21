From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 0/7] phylib MMD accessor cleanups
Date: Tue, 21 Mar 2017 16:22:58 +0100
Message-ID: <20170321152258.GC30655@lunn.ch>
References: <20170319105943.GR21222@n2100.armlinux.org.uk>
 <0b44bbd9-2be9-85cb-1518-4e4ec36927e1@gmail.com>
 <20170321130912.GY21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, linux-usb@vger.kernel.org,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, Woojung Huh <woojung.huh@microchip.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55247 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932750AbdCUPXB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 11:23:01 -0400
Content-Disposition: inline
In-Reply-To: <20170321130912.GY21222@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Thanks.  When I posted this last time around (19th Jan) I mentioned
> about marking the old _indirect() accessors with __deprecated - is
> that still something we want to do?
> 
> I haven't tested this against net-next yet, so I don't know if there
> are any new users of the indirect accessors - going down the deprecated
> route would avoid breakage, but means having to submit a patch later to
> actually remove them.
> 
> How would people want this handled?

Hi Russell

We can get patches into net-next very quickly. So i suggest you rebase
and resubmit and get it in. If something breaks, we add followup
patches to fix it.

	Andrew
