From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: Please pull 'ssb-drivers' branch of wireless-2.6
Date: Wed, 19 Sep 2007 14:33:56 -0700
Message-ID: <20070919213356.GB15510@suse.de>
References: <20070919204428.GE5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	linux-usb-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070919204428.GE5483-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 04:44:28PM -0400, John W. Linville wrote:
> Jeff, Greg, Gary, and Dave,
> 
> These patches build upon the SSB bus support added to net-2.6.24 to
> support the b43 wireless driver.  Since Dave has that support in his
> tree, I'm asking him to merge these patches as well.
> 
> The first patch changes b44 from being a PCI (i.e. SSB-in-drag)
> device to being a native SSB device.  This has little effect one
> way or the other for laptop/desktop/server machines.  But, some
> embedded devices have b44 hardware but no PCI bus (i.e. just SSB).
> This patch enables the use of the b44 driver on that hardware.
> 
> The second patch adds a driver for a USB OHCI device which lives on
> the SSB bus.  Again, this is found on a number of SoC devices used
> especially in wireless routers and APs.
> 
> Thanks for reviewing/ACKing/merging!
> 
> John
> 
> ---
> 
> The patches are available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/ssb-drivers/0001-b44-port-to-native-ssb-support.patch
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/ssb-drivers/0002-usb-ssb-hosted-OHCI-driver.patch

This one needs to go through the linux-usb-devel list (not the -users
list) and get acked by David Brownell, the current OHCI maintainer.

thanks,

greg k-h
