From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 2/3] b43: Fix oops if firmware is not available
Date: Sun, 12 Jan 2014 09:40:39 +0100
Message-ID: <1389516039.5242.1.camel@jlt4.sipsolutions.net>
References: <1389469714-13040-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1389469714-13040-3-git-send-email-Larry.Finger@lwfinger.net>
	 <1389497251.3720.40.camel@deadeye.wl.decadent.org.uk>
	 <52D21226.4070306@lwfinger.net>
	 <1389500647.3720.51.camel@deadeye.wl.decadent.org.uk>
	 (sfid-20140112_052455_040829_49454E3C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1389500647.3720.51.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org> (sfid-20140112_052455_040829_49454E3C)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-01-12 at 04:24 +0000, Ben Hutchings wrote:

> You could switch back to synchronous firmware loading soon, as it's not
> going to support a usermode helper any more.
> 
> But until then, the proper fix for this is going to be to cancel the
> waiter earlier in teardown.

I don't think we found a way when we looked at this, and instead made
the module unload wait for the request_firmware callback to come back
(see all users of the request_firmware_complete struct member in
iwlwifi/iwl-drv.c)

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
