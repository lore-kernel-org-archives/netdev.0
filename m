From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: small design problem with hso driver
Date: Wed, 8 Oct 2008 10:45:56 -0700
Message-ID: <20081008174556.GA15387@kroah.com>
References: <48ECBB26.7080402@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48ECBB26.7080402-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 08, 2008 at 03:52:38PM +0200, Denis Joseph Barrow wrote:
> Hi,
> I'm getting a fairly consistently reproducable problem
> with the 3g modem hso driver. The most reproducable
> bug I have.
> 
> It happens when I plug out the usb modem & ctrl-c
> out of an ioctl call with the modem connected in paralell over ppp
> with wvdial 
> 
> Basically whats happening is the hso_serial_close
> is being called more times than the hso_serial_open &
> I don't know why.

Care to put a trace or printk() to determine who is doing each open and
close?

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
