From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net: dsa: remove unnecessary phy.h include
Date: Wed, 18 Jan 2017 16:37:14 -0500 (EST)
Message-ID: <20170118.163714.6755964924380784.davem@davemloft.net>
References: <20170118001403.GJ27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux@armlinux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118001403.GJ27312@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Wed, 18 Jan 2017 00:14:03 +0000

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

Applied, thanks.
