From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Wed, 23 Nov 2016 17:58:14 +0100
Message-ID: <20161123165814.GA8760@lunn.ch>
References: <20161122103944.31381-1-stefan.eichenberger@netmodule.com>
 <20161122150330.GE2691@lunn.ch>
 <20161122183732.GD13973@gruene.netmodule.intranet>
 <20161122190206.GE14947@lunn.ch>
 <20161123120047.GC12698@gruene.netmodule.intranet>
 <87shqi89wu.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
 <20161123165022.GD12698@gruene.netmodule.intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Stefan Eichenberger <eichest@gmail.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50020 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751167AbcKWQ6S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 11:58:18 -0500
Content-Disposition: inline
In-Reply-To: <20161123165022.GD12698@gruene.netmodule.intranet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 9:8    Frame Mode:   00 -> Normal Network
>                      01 -> DSA (FRAME_MODE_DSA)
>                      10 -> Provider (FRAME_MODE_PROVIDER)
>                      11 -> Ether Type DSA (FRAME_ETHER_TYPE_DSA)

Ah, there is one issue. This device supports EDSA. However,
MV88E6XXX_FLAGS_FAMILY_6097 does not list MV88E6XXX_FLAG_EDSA.

Without that flag set, the code assumes the device can only do DSA,
using the older definition of this register.

    Andrew
