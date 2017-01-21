From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/8] net: dsa: mv88e6xxx: Implement external
 MDIO bus on mv88e6390
Date: Sat, 21 Jan 2017 17:07:42 +0100
Message-ID: <20170121160742.GA7808@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
 <1484955062-26718-2-git-send-email-andrew@lunn.ch>
 <28da5ac2-acb8-f869-db7d-0772868dac69@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40594 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750836AbdAUQIT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 21 Jan 2017 11:08:19 -0500
Content-Disposition: inline
In-Reply-To: <28da5ac2-acb8-f869-db7d-0772868dac69@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This looks fine, although I am not clear why we cannot utilize a
> standard representation of a MDIO bus (with PHY devices as child nodes)
> which has a specific compatible string, e.g:
> marvell,mv88e6390-external-mdio, and that is a child node of the 6390
> Ethernet switch itself, something like:

Humm, interesting idea. I did not think of this, because the current
code just looks for an mdio property, and does not care about any
compatible string.

I will think about this.

Thanks

  Andrew
