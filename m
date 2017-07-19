From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Enable CMODE config support for
 6390X
Date: Wed, 19 Jul 2017 15:25:28 +0200
Message-ID: <20170719132528.GA2098@lunn.ch>
References: <20170719061702.7692-1-mnhu@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Martin =?iso-8859-1?Q?Hundeb=F8ll?= <mnhu@prevas.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33389 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752811AbdGSNZe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 09:25:34 -0400
Content-Disposition: inline
In-Reply-To: <20170719061702.7692-1-mnhu@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 08:17:02AM +0200, Martin Hundebøll wrote:
> Commit f39908d3b1c45 ('net: dsa: mv88e6xxx: Set the CMODE for mv88e6390
> ports 9 & 10') added support for setting the CMODE for the 6390X family,
> but only enabled it for 9290 and 6390 - and left out 6390X.
> 
> Fix support for setting the CMODE on 6390X also by assigning
> mv88e6390x_port_set_cmode() to the .port_set_cmode function pointer in
> mv88e6390x_ops too.
> 
> Signed-off-by: Martin Hundebøll <mnhu@prevas.dk>

Duh!

Fixes: f39908d3b1c4 ("net: dsa: mv88e6xxx: Set the CMODE for mv88e6390 ports 9 & 10")
Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
