From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 1/2] net: dsa: bcm_sf2: Do not clobber b53_switch_ops
Date: Sun, 8 Jan 2017 21:17:05 +0100
Message-ID: <20170108201705.GF21101@lunn.ch>
References: <20170108050157.16302-1-f.fainelli@gmail.com>
 <20170108050157.16302-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48674 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964838AbdAHURG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 15:17:06 -0500
Content-Disposition: inline
In-Reply-To: <20170108050157.16302-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 07, 2017 at 09:01:56PM -0800, Florian Fainelli wrote:
> We make the bcm_sf2 driver override ds->ops which points to
> b53_switch_ops since b53_switch_alloc() did the assignent. This is all
> well and good until a second b53 switch comes in, and ends up using the
> bcm_sf2 operations. Make a proper local copy, substitute the ds->ops
> pointer and then override the operations.
> 
> Fixes: f458995b9ad8 ("net: dsa: bcm_sf2: Utilize core B53 driver when possible")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
