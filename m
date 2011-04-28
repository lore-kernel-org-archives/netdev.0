From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv7] usbnet: Resubmit interrupt URB if device is open
Date: Wed, 27 Apr 2011 23:00:11 -0700 (PDT)
Message-ID: <20110427.230011.59678907.davem@davemloft.net>
References: <201104240836.47491.oliver@neukum.org>
	<20110426172059.4C9B320242@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110426172059.4C9B320242-6A69KNNYBwgF248FYctl9mCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Date: Tue, 26 Apr 2011 09:58:32 -0700

> Resubmit interrupt URB if device is open.  Use a flag set in
> usbnet_open() to determine this state.  Also kill and free
> interrupt URB in usbnet_disconnect().
> 
> Signed-off-by: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

This doesn't apply at all to Linus's current tree.

Several new EVENT_* flags have been added, and usbnet_resume() does
a lot more things than whatever version your patch is against.

I'm not going to pick a new value EVENT_* mask and force the rest of
this to apply, because all of these other changes that have happened
to the driver meanwhile might interact with your changes in ways I
won't understand.

You'll therefore need to look this over and submit a patch which will
apply cleanly.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
