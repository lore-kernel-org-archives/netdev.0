From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: small design problem with hso driver
Date: Thu, 9 Oct 2008 10:32:59 +0100
Message-ID: <20081009103259.066cc94a@lxorguk.ukuu.org.uk>
References: <48ECBB26.7080402@option.com>
	<20081008174556.GA15387@kroah.com>
	<48EDC887.8010403@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48EDC887.8010403-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Surely if the driver returns an error code on hso_serial_open
> hso_serial_close shouldn't be called
> or have I a complete misunderstanding
> of char driver semantics.

Generally yes that would be sane. The tty layer has always called the
close method of drivers on a failed open and the drivers are all written
assuming that.

It would be nice to change but there are far bigger fish to fry.

Alan
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
