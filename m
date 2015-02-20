From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] hso: always read interface number from the current
 altsetting
Date: Fri, 20 Feb 2015 16:49:17 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1502201645430.1335-100000@iolanthe.rowland.org>
References: <20150220.152156.1455455304724247882.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org, <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150220.152156.1455455304724247882.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Feb 2015, David Miller wrote:

> From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
> Date: Tue, 17 Feb 2015 11:31:29 +0100
> 
> > Always read bInterfaceNumber from the current altsetting, not from the first one
> > available in the altsetting array. This is coming from code review, not related
> > to any specific bug.
> > 
> > Signed-off-by: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>

It doesn't matter.  The bInterfaceNumber values are guaranteed to be 
the same for all altsettings in a particular interface, because of the 
way the altsetting arrays are constructed.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
