From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv2 net-next-2.6] rndis_host: Poll status before control
 channel where necessary
Date: Wed, 13 Apr 2011 14:49:26 -0700 (PDT)
Message-ID: <20110413.144926.200377904.davem@davemloft.net>
References: <1302670523.5282.610.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vzeeaxwl-ubggFOsnOr3gwBMGfI3FeA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1302670523.5282.610.camel@localhost>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Date: Wed, 13 Apr 2011 05:55:23 +0100

> Some RNDIS devices don't respond on the control channel until polled
> on the status channel.  In particular, this was reported to be the
> case for the 2Wire HomePortal 1000SW and for some Windows Mobile
> devices.
> 
> This is roughly based on a patch by John Carr <john.carr-3P/l8hQepEe9FHfhHBbuYA@public.gmane.org>
> which is currently applied by Mandriva.
> 
> Reported-by: Mark Glassberg <vzeeaxwl-ubggFOsnOr3gwBMGfI3FeA@public.gmane.org>
> Signed-off-by: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
> ---
> The first version made this behaviour unconditional and had to be
> reverted.  This version adds a quirk flag instead.

Applied, thanks Ben.

The feedback about whether to use the point-to-point flag or not should
be addressed, but seperately.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
