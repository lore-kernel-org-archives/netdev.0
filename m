From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC] net: dsa: remove unnecessary phy.h include
Date: Tue, 17 Jan 2017 20:11:51 -0500
Message-ID: <87a8ap18a0.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170118001403.GJ27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118001403.GJ27312@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Russell,

Russell King - ARM Linux <linux@armlinux.org.uk> writes:

> Including phy.h and phy_fixed.h into net/dsa.h causes phy*.h to be an
> unnecessary dependency for quite a large amount of the kernel.  There's
> very little which actually requires definitions from phy.h in net/dsa.h
> - the include itself only wants the declaration of a couple of
> structures and IFNAMSIZ.
>
> Add linux/if.h for IFNAMSIZ, declarations for the structures, phy.h to
> mv88e6xxx.h as it needs it for phy_interface_t, and remove both phy.h
> and phy_fixed.h from net/dsa.h.
>
> This patch reduces from around 800 files rebuilt to around 40 - even
> with ccache, the time difference is noticable.
>
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

This patch applies cleanly on net-next and builds correctly after
touching include/linux/phy.h. My boards work fine with it.

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
