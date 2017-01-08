From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 2/2] net: dsa: bcm_sf2: Utilize nested MDIO read/write
Date: Sun, 8 Jan 2017 18:41:40 +0100
Message-ID: <20170108174140.GB21101@lunn.ch>
References: <20170108050157.16302-1-f.fainelli@gmail.com>
 <20170108050157.16302-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46233 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753503AbdAHRlm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 12:41:42 -0500
Content-Disposition: inline
In-Reply-To: <20170108050157.16302-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 07, 2017 at 09:01:57PM -0800, Florian Fainelli wrote:
> We are implementing a MDIO bus which is behind another one, so use the
> nested version of the accessors to get lockdep annotations correct.
> 
> Fixes: 461cd1b03e32 ("net: dsa: bcm_sf2: Register our slave MDIO bus")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
