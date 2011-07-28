From: Marek Vasut <marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] ASIX: Use only 11 bits of header for data size
Date: Thu, 28 Jul 2011 18:17:49 +0200
Message-ID: <201107281817.49843.marek.vasut@gmail.com>
References: <1311734687-23551-1-git-send-email-marek.vasut@gmail.com> <201107280806.18813.marek.vasut@gmail.com> <20110728151806.GB22202@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110728151806.GB22202-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday, July 28, 2011 05:18:06 PM Greg KH wrote:
> On Thu, Jul 28, 2011 at 08:06:18AM +0200, Marek Vasut wrote:
> > On Thursday, July 28, 2011 07:40:29 AM David Miller wrote:
> > > From: Marek Vasut <marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > Date: Wed, 27 Jul 2011 04:44:47 +0200
> > > 
> > > > The AX88772B uses only 11 bits of the header for the actual size. The
> > > > other bits
> > > > 
> > > > are used for something else. This causes dmesg full of messages:
> > > > 	asix_rx_fixup() Bad Header Length
> > > > 
> > > > This patch trims the check to only 11 bits. I believe on older chips,
> > > > the remaining 5 top bits are unused.
> > > > 
> > > > Signed-off-by: Marek Vasut <marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > 
> > > Applied.
> > 
> > Hi, did you test it ?
> > 
> > I left NOTEs outside the commit message:
> > 
> > NOTE: If possible, can someone test/verify this patch with other ASIX
> > chips ? NOTE2: If Ack-ed, Greg, can you get this into -stable?
> 
> <formletter>
> 
> This is not the correct way to submit patches for inclusion in the
> stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
> for how to do this properly.

Yea I know ... I'm just so very tired (read dead). Sorry
> 
> </formletter>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
