From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Mon, 27 Jul 2009 22:07:36 +0800
Message-ID: <20090727140736.GA1864@darkstar>
References: <4A6AD807.6060706@hartkopp.net> <20090725115011.7ddf8d00@lxorguk.ukuu.org.uk> <1248520053.28545.156.camel@violet> <20090725131046.0f076f37@lxorguk.ukuu.org.uk> <20090727095904.GA5442@darkstar> <4A6D8BA3.3030601@hartkopp.net> <4A6D91D7.6030204@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A6D91D7.6030204-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2009 at 01:39:03PM +0200, Oliver Hartkopp wrote:
> Oliver Hartkopp wrote:
> > Dave Young wrote:
> >> On Sat, Jul 25, 2009 at 01:10:46PM +0100, Alan Cox wrote:
> >>>>> tty_register_device appears to have been called with a NULL pointer. Not
> >>>>> sure why however.
> >>>> if that is the pointer for the struct device, then that used to be fine
> >>>> in the past. Not all RFCOMM device have a parent when they are created.
> >>> The tty layer doesn't care about the struct device really. Nothing there
> >>> has changed. The NULL passed appears to be the driver argument.
> >> Agree with you, because in rfcomm_init, rfcomm thread run before tty initilized, the following patch may fix the problem.
> >> oliver, could you verify it it fix your problem?
> > 
> > Hi Dave,
> > 
> > i get this problem really seldom on my Laptop and i did not manage to get a
> > reproducible Oops of that problem.
> > 
> > Anyway the code you are pointing to seems to have a problem and your added
> > error handling looks good to me - even if i don't know if the initializations
> > can be reordered in that way.
> > 
> > I'll try your patch, but it could take a *long* time to prove it right ;-)
> > 
> 
> Just FYI:
> 
> Your patch compiled, the system booted without problems and nothing is broken
> so far. I checked the BT, WLAN and BT dial-up with success. So it looks good
> to me.

Thanks for the testing. Marcel, could you take a look? 

> 
> Regards,
> Oliver
