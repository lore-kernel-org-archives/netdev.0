From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/4] net: dsa: mv88e6xxx: Allow mv88e6xxx_smi_init() to
 be used at address 0x1
Date: Mon, 19 Dec 2016 16:00:08 +0100
Message-ID: <20161219150008.GE10048@lunn.ch>
References: <20161219141610.30934-1-romain.perier@free-electrons.com>
 <20161219141610.30934-2-romain.perier@free-electrons.com>
 <20161219143848.GA10048@lunn.ch>
 <292d4f15-c58b-3565-26ec-98a025b6adb3@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>
To: Romain Perier <romain.perier@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58690 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752680AbcLSPAN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 10:00:13 -0500
Content-Disposition: inline
In-Reply-To: <292d4f15-c58b-3565-26ec-98a025b6adb3@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 03:56:34PM +0100, Romain Perier wrote:
> Hi Andrew,
> 
> Le 19/12/2016 à 15:38, Andrew Lunn a écrit :
> >On Mon, Dec 19, 2016 at 03:16:06PM +0100, Romain Perier wrote:
> >>Currently, the function mv88e6xxx_smi_init() returns -EINVAL if the bit
> >>zero of sw_addr is 0x1. However, on some platforms, ethernet switches
> >>are configured in Multi chip addressing mode and available at MDIO
> >>address 0x1.
> >
> >Hi Romain
> >
> >What branch is this against? net-next?
> 
> Until last friday it was based onto next-20161216, I rebased onto
> the torvalds's tree this morning (so ~4.10-pre-rc1).

This patchset is 80% networking. So please see:

Documentation/networking/netdev-FAQ.txt

> Oh, it's already fixed, good. I did not see this patch :)
> 
> >
> >It would be nicer to use Volodymyr, since it has been reviewed.
> 
> 
> As the fix is already there, I will use it, sure.

Im not sure what happened to it. It might of fallen through the
cracks. Lets see what Volodymyr says. It might need resubmitting once
netdev reopens.

       Andrew
