From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 09:06:36 -0700
Message-ID: <20080415160636.GA9704@kroah.com>
References: <20080414213238.GB28833@kroah.com> <200804151344.42085.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200804151344.42085.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 15, 2008 at 01:44:40PM +0200, Oliver Neukum wrote:
> Am Montag, 14. April 2008 23:32:39 schrieb Greg KH:
> > Hi all,
> > 
> > Here's a patch that I have cleaned up for context only from Option that
> > is a USB serial / network device all in one.
> > 
> > I'd like to see this go into 2.6.26, so any review comments by anyone
> > who wishes to review any portion of this would be greatly apprecited.
> 
> Hi,
> 
> this patch against Greg's version with Pauliaus patch applied
> 
> - uses correct CDC includes and constants
> - fixes a race between disconnect and open
> - fixes a race between probe and open
> - corrects incorrect uses of GFP_KERNEL
> - adds some error handling in open
> - fixes races in access to urb->status
> 
> There's still a race condition in the write path left and the autosuspend
> handling is broken in extremely interesting ways. The next patch will fix
> these and I am still doing further reviews.

Thanks a lot for these changes, I've applied them to the driver.

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
