From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 3/3] arm64: dts: marvell: Add ethernet switch
 definition for the ESPRESSObin
Date: Tue, 20 Dec 2016 17:17:14 +0100
Message-ID: <20161220161714.GD30952@lunn.ch>
References: <20161220085138.3998-1-romain.perier@free-electrons.com>
 <20161220085138.3998-4-romain.perier@free-electrons.com>
 <20161220154234.GC30952@lunn.ch>
 <c27998fd-3807-5c99-382b-b8d0d0f06526@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
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
Received: from vps0.lunn.ch ([178.209.37.122]:33353 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932234AbcLTQRT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Dec 2016 11:17:19 -0500
Content-Disposition: inline
In-Reply-To: <c27998fd-3807-5c99-382b-b8d0d0f06526@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >>+		mdio {
> >>+			#address-cells = <1>;
> >>+			#size-cells = <0>;
> >>+			reg = <1>;
> >
> >what is this reg value for?
> >
> >     Andrew
> >
> 
> It was required to avoid a warning thrown by the mdio subsystem

Do you remember what the warning was?

This seems odd to me. I don't see why a reg is needed here.

Thanks
	Andrew
