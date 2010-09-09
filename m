From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH v3] cxacru: ignore cx82310_eth devices
Date: Wed, 8 Sep 2010 23:25:47 -0700
Message-ID: <20100909062547.GA1774@kroah.com>
References: <20100908.131227.28827971.davem@davemloft.net> <201009082252.15865.linux@rainbow-software.org> <20100909033557.GA3723@kroah.com> <20100908.230747.71591658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@rainbow-software.org, simon@fire.lp0.eu,
	dbrownell@users.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100908.230747.71591658.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 08, 2010 at 11:07:47PM -0700, David Miller wrote:
> From: Greg KH <greg@kroah.com>
> Date: Wed, 8 Sep 2010 20:35:57 -0700
> 
> > On Wed, Sep 08, 2010 at 10:52:12PM +0200, Ondrej Zary wrote:
> >> Ignore ADSL routers, which can have the same vendor and product IDs
> >> as ADSL modems but should be handled by the cx82310_eth driver.
> >> 
> >> This intentionally ignores device IDs that aren't currently handled
> >> by cx82310_eth. There may be other device IDs that perhaps shouldn't
> >> be claimed by cxacru.
> > 
> > Looks good, thanks, I'll go queue it up.
> 
> Greg, see my reply, I already tossed this into net-next-2.6

Ah, that's fine, thanks for doing this, much appreciated.

greg k-h
