From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Sat, 25 Jul 2009 13:10:46 +0100
Message-ID: <20090725131046.0f076f37@lxorguk.ukuu.org.uk>
References: <4A6AD807.6060706@hartkopp.net>
	<20090725115011.7ddf8d00@lxorguk.ukuu.org.uk>
	<1248520053.28545.156.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1248520053.28545.156.camel@violet>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > tty_register_device appears to have been called with a NULL pointer. Not
> > sure why however.
> 
> if that is the pointer for the struct device, then that used to be fine
> in the past. Not all RFCOMM device have a parent when they are created.

The tty layer doesn't care about the struct device really. Nothing there
has changed. The NULL passed appears to be the driver argument.
