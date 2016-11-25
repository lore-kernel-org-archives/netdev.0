From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 10:53:50 +0100
Message-ID: <20161125095350.GA20653@kroah.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
 <20161125002702.GA14085@electric-eye.fr.zoreil.com>
 <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 24, 2016 at 10:49:33PM -0500, Mark Lord wrote:
> There is no possibility for them to be used for anything other than
> USB receive buffers, for this driver only.  Nothing in the driver
> or kernel ever writes to those buffers after initial allocation,
> and only the driver and USB host controller ever have pointers to the buffers.

You really are going to have to break out that USB monitor to verify
that this is the data coming across the wire.  Note, there are "cheap"
USB monitors that can be quite handy and that work on Linux:
	http://www.totalphase.com/products/beagle-usb12/

Or most high-end scopes have a USB mode that you can use to catch stuff
like this (but they are usually harder to use/trigger and only store a
very limited buffer).

good luck!

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
