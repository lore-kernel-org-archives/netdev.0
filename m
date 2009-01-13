From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [patch v2] net/usb: remove err() messages in few drivers
Date: Tue, 13 Jan 2009 01:44:25 -0800
Message-ID: <200901130144.26162.david-b@pacbell.net>
References: <1231805322.12962.4.camel@tux.localhost> <208cbae30901130057r2b3396f4gb5abdedd5647739c@mail.gmail.com> <200901131025.40285.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, "Greg KH" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"Alexey Klimov" <klimov.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200901131025.40285.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 January 2009, Oliver Neukum wrote:
> > Ok, i'll reformat patch. Is it okay if i use kaweth->dev->dev,
> > kaweth->net->dev and intf->dev ? Or switch to kaweth->net->dev
> > (instead of dev->dev)?
> 
> kaweth in kaweth_disconnect() frees the network device. Therefore
> you cannot use it. You'd access freed memory. Pick one of the others
> and stay with it.

intf->dev is going to be "obviously correct", the others aren't.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
