From: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/7 v3] initdev:kernel:USB init device discovery
	notification
Date: Fri, 7 Aug 2009 10:42:09 -0700
Message-ID: <20090807174209.GB30450@cuplxvomd02.corp.sa.net>
References: <9b2b86520908070832p2d1658b0t8b1d89d1a034bb9a@mail.gmail.com> <Pine.LNX.4.44L0.0908071142260.3063-100000@iolanthe.rowland.org> <9b2b86520908071017h606e595fr4488d6ff61cb337c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: Alan Jenkins <sourcejedi.lkml-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9b2b86520908071017h606e595fr4488d6ff61cb337c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 07, 2009 at 06:17:51PM +0100, Alan Jenkins wrote:
> On 8/7/09, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org> wrote:
> > On Fri, 7 Aug 2009, Alan Jenkins wrote:
> >
> >> > +/* The mask of possible USB boot devices depends on what drivers and
> >> > + * options have been configured into the kernel.  There are too many
> >> > + * USB network config options to list here, so just assume it is always
> >> > + * possible to have a USB network device.
> >> > + */
> >>
> >> That could be fixed though.  Make the "USB Network Adaptors" menu into
> >> an option.  Then you just have e.g. "CONFIG_NETDEV_USB", plus the two
> >> class devices outside the menu (CONFIG_USB_ACM and CONFIG_USB_WDM).
> 
> Oops, scratch WDM.  It doesn't actually provide a network device
> (otherwise it would depend on NET).
> 
> > That could be done.  It might even meet with the approval of the
> > networking maintainer, independent of this patch series.
> >
> > But what if somebody adds yet another networking class driver outside
> > the menu?
> 
> Hmm.
> 
> Ok, how about a single (hidden) USB_HAS_NETDEV.  NETDEV_USB and
> USB_ACM select USB_HAS_NETDEV.
> 
> Textual juxtaposition or simple copy+paste inside class/Kconfig should
> help it get picked up.  And I'd add a comment pointing the bewildered
> to the definition of usb_initdev_mask.
> 
> I'll write a patch for your inspection this evening.

I remember thinking about this and seem to recall that Alan Stern and I
tossed this idea around, but didn't act on it. Such a thing holds potential
for avoiding an unnecessary delay during boot. Whether it actually makes
things faster in a given configuration will depend on that configuration's
critical path, but I would welcome such a patch on the basis that it's
unlikely to hurt and could improve boot times in some circumstances.

> Alan
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
