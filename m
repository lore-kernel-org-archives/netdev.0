From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH 11/11] usb: core: fix a race with usb_queue_reset_device()
Date: Wed, 21 Jan 2015 13:52:42 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1501211351560.1670-100000@iolanthe.rowland.org>
References: <20150121135512.GA9889@hposo>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150121135512.GA9889@hposo>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Jan 2015, Olivier Sobrie wrote:

> I tested your patch. It also fixes the problem I observed.
> You can drop mine.
> 
> For your info:
> 
> My test consists in powering down a usb hso modem while one of its
> serial port is opened. It leads to two URB failures, each urb callback
> queues a reset.
> Without your fix (or without the one I sent), a crash happens after
> less than ~20 power up/down sequences. With your fix, after more than
> 1000 power up/down I don't see any crash.

Okay, I'll submit the patch.  Thanks for testing it.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
