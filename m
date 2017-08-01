From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 00/13] phylink and sfp support
Date: Tue, 1 Aug 2017 16:39:33 +0200
Message-ID: <20170801143933.GI23157@lunn.ch>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47934 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751368AbdHAOji (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 10:39:38 -0400
Content-Disposition: inline
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 03:01:39PM +0100, Russell King - ARM Linux wrote:
> Hi,
> 
> This patch series introduces generic support for SFP sockets found on
> various Marvell based platforms.  The idea here is to provide common
> SFP socket support which can be re-used by network drivers as
> appropriate, rather than each network driver having to re-implement
> SFP socket support.

There is a lot of code here, and i'm not really going to understand it
until i use it. I have a couple of boards with SFFs connected to
switches, so i will spend some time over the next month or so to make
DSA use phylink. As is usual, we can sort out any issues as we go
along.

David, if it still applies cleanly, can you add it to net-next?

       Thanks
	Andrew
