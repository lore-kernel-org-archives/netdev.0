From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA support for Micrel KSZ8895
Date: Wed, 16 Aug 2017 16:04:51 +0200
Message-ID: <20170816140451.GA13006@lunn.ch>
References: <20170816075524.GA18532@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com, Woojung.Huh@microchip.com
To: Pavel Machek <pavel@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170816075524.GA18532@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2017 at 09:55:24AM +0200, Pavel Machek wrote:
> Hi!
> 
> I've got hardware with KSZ8895, and I'd like to use switch ports as
> separate ethernet cards. I believe that means DSA support.
> 
> And there are even patches available from microchip... unfortunately
> they are in strange form and for v3.18.
> 
> http://www.microchip.com/SWLibraryWeb/product.aspx?product=KSZ8895%20Software%20Linux%203.18
> 
> Is there newer version of the driver available somewhere? Is the
> driver good starting point, or should I start with something else?

Hi Pavel

Woojung is the expert here. His DSA driver for the 9477 is a nice
clean driver.

Have you compared the 8895 to the 9477. Are they similar? Could the
existing 9477 be extended to support the 8895?

	 Andrew
