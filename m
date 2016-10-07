From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: HSO driver patch [1/2]
Date: Fri, 7 Oct 2016 16:38:21 +0200
Message-ID: <20161007143821.GA26768@kroah.com>
References: <CAHMF36FfubzNOcaud613oVuM4YZoC_y29GtMC_h7HDNLOSm8Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matej Kupljen <matej.kupljen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAHMF36FfubzNOcaud613oVuM4YZoC_y29GtMC_h7HDNLOSm8Ew-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 07, 2016 at 04:29:42PM +0200, Matej Kupljen wrote:
> Hi,
> 
> 
> I am using hso driver for my 3G modem (although different manufacturer
> with different USB VID/PID) but I have some problems with it. It is
> working fine, but if you disconnect the USB connection while the data
> is transferring trough AT interface, we get a crash.
> 
> There are two patches:
>  1.) 0001-Reverse-the-order-in-disconnect.patch
>       This patch first sets the interface to NULL and only then starts
> removing the allocated
>       resources. This is according to documentation and it is also
> more similar to other drivers.
>  2.) 0002-Stop-also-serial-queue-when-device-is-unplugged.patch
>       Serial device was not stopped when the device got unplugged so
> there are continues error
>       messages that the URB cannot be submitted.

Again, patches can not be attached, they just need to be inline, with
the needed information.

Look at the patches on the mailing lists for plenty of examples of how
to do this.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
