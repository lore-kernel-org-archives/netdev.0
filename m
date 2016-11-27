From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Fix
 mv88e6xxx_g1_irq_free() interrupt count
Date: Sun, 27 Nov 2016 23:30:12 +0100
Message-ID: <20161127223012.GA26982@lunn.ch>
References: <1480285588-13501-1-git-send-email-afaerber@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        Bed??icha Ko??atu <bedrich.kosata@nic.cz>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58849 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752717AbcK0WaT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 17:30:19 -0500
Content-Disposition: inline
In-Reply-To: <1480285588-13501-1-git-send-email-afaerber@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 11:26:28PM +0100, Andreas Färber wrote:
> mv88e6xxx_g1_irq_setup() sets up chip->g1_irq.nirqs interrupt mappings,
> so free the same amount. This will be 8 or 9 in practice, less than 16.
> 
> Fixes: dc30c35be720 ("net: dsa: mv88e6xxx: Implement interrupt support.")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Andreas Färber <afaerber@suse.de>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
    Andrew
