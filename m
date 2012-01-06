From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 1/3] usbnet: make ethtool_ops const
Date: Fri, 6 Jan 2012 05:34:25 -0800
Message-ID: <20120106133425.GC9279@suse.de>
References: <20120106051022.712047093@vyatta.com>
 <20120106051050.936477418@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120106051050.936477418-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 05, 2012 at 09:10:23PM -0800, Stephen Hemminger wrote:
> The ethtool_ops table of function pointers should be const.
> Fix all the usb network drivers.
> 
> Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
> 
> ---
> Not sure if you want these through net-next or usb-next?
> 
>  drivers/net/usb/asix.c       |    2 +-
>  drivers/net/usb/cdc_ncm.c    |    4 ++--
>  drivers/net/usb/ipheth.c     |    2 +-
>  drivers/net/usb/sierra_net.c |    2 +-
>  4 files changed, 5 insertions(+), 5 deletions(-)

drivers/net/usb/ patches go through David and net-next, not me.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
