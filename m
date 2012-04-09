From: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big network copies (page allocation failure)
Date: Mon, 9 Apr 2012 11:36:32 -0700
Message-ID: <20120409183632.GO29342@merlins.org>
References: <20120329163800.GH24933@merlins.org> <1333044575.2656.1.camel@bwh-desktop.uk.solarflarecom.com> <20120409172051.GR32290@merlins.org> <20120409.141241.1216091936509309354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120409.141241.1216091936509309354.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2012 at 02:12:41PM -0400, David Miller wrote:
> From: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
> Date: Mon, 9 Apr 2012 10:20:51 -0700
> 
> > Any idea what's going on, what bucket of RAM is an issue for the driver
> > (total RAM is more than plenty), and where I should go from there?
> 
> The wireless layer is allocating high-order pages, so it's
> not the amount of ram, it's the fragmentation of it leading
> to a lack of those high-order pages.

I figured it was something of the sort, thanks for the professional
confirmation :)

What's my next step, file a bug with a specific team?

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
