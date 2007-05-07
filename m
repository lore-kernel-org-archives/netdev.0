From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 1/2] Add 93cx6 eeprom library
Date: Mon, 7 May 2007 11:34:50 -0400
Message-ID: <20070507153450.GC5125@tuxdriver.com>
References: <200705070346.04982.flamingice@sourmilk.net> <20070507142715.GB32546@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
To: Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070507142715.GB32546-elnMNo+KYs3pIgCt6eIbzw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 02:27:15PM +0000, Ben Dooks wrote:
> On Mon, May 07, 2007 at 03:46:04AM -0400, Michael Wu wrote:
> > From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > 
> > This patch adds a library for reading from and writing to 93cx6 eeproms.
> 
> This looks remarkably like an SPI device, why not use the
> spi framework to drive this?

This isn't intended to be a user-visible device.  Rather, it
is a support library for internal use by drivers to read hardware
configuration info, etc.  Given that, do we really need something as
heavy as implementing an SPI master, etc?

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
