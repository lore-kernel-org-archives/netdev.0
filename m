From: Holger Schurig <hs4233-x6+DxXLjN1AJvtFkdXX2Hg4jNU5vUVPG@public.gmane.org>
Subject: Re: [PATCH 1/1] iwmc3200: add more SDIO device ids
Date: Wed, 26 Aug 2009 09:25:03 +0200
Message-ID: <200908260925.03437.hs4233@mail.mn-solutions.de>
References: <1251149659-32212-1-git-send-email-tomas.winkler@intel.com> <1ba2fa240908241520q5be2060co145ec0745954dcf0@mail.gmail.com> <1251156118.2950.82.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1251156118.2950.82.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 August 2009 01:21:58 Marcel Holtmann wrote:
> My personal vote is for keeping all IDs inside the drivers.
> And I also prefer to keep the plain hex values and just put a
> comment above them which device this is. Something like this:
>
> static struct usb_device_id btusb_table[] = {
> 	/* Generic Bluetooth USB device */
> 	{ USB_DEVICE_INFO(0xe0, 0x01, 0x01) },

+1

When I have an unknown device (and not compiled all modules) it's 
so much easier to do an

grep -ri 057c drivers/usb

then to do the same on include/ and then again to find the driver 
that uses this id. For the same reason, I prefer 0x057c in the 
source and not 0x57c.

-- 
http://www.holgerschurig.de
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
