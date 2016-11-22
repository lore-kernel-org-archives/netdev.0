From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/5] net: phy: bcm7xxx: Add support for
 downshift/Wirespeed
Date: Tue, 22 Nov 2016 21:57:47 +0100
Message-ID: <20161122205747.GH14947@lunn.ch>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
 <20161122194058.29820-5-f.fainelli@gmail.com>
 <20161122200228.GG14947@lunn.ch>
 <1902f0f0-46e5-d3b3-90c1-10867f4fb826@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48940 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756875AbcKVU5u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 15:57:50 -0500
Content-Disposition: inline
In-Reply-To: <1902f0f0-46e5-d3b3-90c1-10867f4fb826@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Maybe we should think about this locking a bit. It is normal for the
> > lock to be held when using ops in the phy driver structure. The
> > exception is suspend/resume. Maybe we should also take the lock before
> > calling the phydev->drv->get_tunable() and phydev->drv->set_tunable()?
> 
> Yes, that certainly seems like a good approach to me, let me cook a
> patch doing that.

Hi Florian

There are a couple of mutex locks/unlocks you will need to remove from
mscc.c when you centralize this mutex.

       Andrew
