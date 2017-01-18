From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH RFC] net: dsa: remove unnecessary phy.h include
Date: Wed, 18 Jan 2017 21:46:28 +0000
Message-ID: <20170118214628.GO27312@n2100.armlinux.org.uk>
References: <20170118001403.GJ27312@n2100.armlinux.org.uk>
 <20170118.163714.6755964924380784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170118.163714.6755964924380784.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2017 at 04:37:14PM -0500, David Miller wrote:
> From: Russell King - ARM Linux <linux@armlinux.org.uk>
> Date: Wed, 18 Jan 2017 00:14:03 +0000
> 
> > Including phy.h and phy_fixed.h into net/dsa.h causes phy*.h to be an
> > unnecessary dependency for quite a large amount of the kernel.  There's
> > very little which actually requires definitions from phy.h in net/dsa.h
> > - the include itself only wants the declaration of a couple of
> > structures and IFNAMSIZ.
> > 
> > Add linux/if.h for IFNAMSIZ, declarations for the structures, phy.h to
> > mv88e6xxx.h as it needs it for phy_interface_t, and remove both phy.h
> > and phy_fixed.h from net/dsa.h.
> > 
> > This patch reduces from around 800 files rebuilt to around 40 - even
> > with ccache, the time difference is noticable.
> > 
> > Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> 
> Applied, thanks.

Hmm, now that's _really_ interesting.

I think you've said to others to send patches with RFC in them when they
aren't to be applied.  I sent this with RFC in, and it still got applied.

This is _really_ unfortunate, as the 0-day builder has been sending me a
stream of build errors over it, and I now have a branch with 9 patches
plus this one in fixing those errors...

And I did say in the comments below the --- that it should be left a few
days for the 0-day builder to run through it and find those errors.

Ho hum.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
