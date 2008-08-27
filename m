From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: question wrt /drivers/char/tty_io.c in pre 2.6.16 code
Date: Wed, 27 Aug 2008 17:37:46 +0100
Message-ID: <20080827173746.11b91c07@lxorguk.ukuu.org.uk>
References: <20080820010353.593820280@mini.kroah.org>
	<20080820010752.GB3365@kroah.com>
	<48B52064.9070700@pobox.com>
	<48B578F3.1050908@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48B578F3.1050908-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> The new tty_insert_flip_string returns the
> number of bytes successfully copied to tty recieve buffers
> how do I implement this functionality in pre 2.6.16 code,
> can it be done?

Probably but it'll be really ugly. You need to stick your nose into the
innards of struct tty_struct and check the space left in the current flip
buffer entry.

What you do if it is full is another question.

Alan.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
