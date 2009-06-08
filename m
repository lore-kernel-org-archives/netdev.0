From: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/7] initdev:kernel:Await console discovery, v6
Date: Mon, 8 Jun 2009 15:13:44 -0700
Message-ID: <20090608221344.GB22222@cuplxvomd02.corp.sa.net>
References: <20090606023407.GA5695@cuplxvomd02.corp.sa.net> <4A2A2EED.3060506@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A2A2EED.3060506-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 06, 2009 at 04:55:09AM -0400, Stefan Richter wrote:
> David VomLehn wrote:
> > Wait for the console device to become available.
> > 
> > History
> > v6	Changed BOOTDEV_* to INITDEV_*.
> > v5.1	Corrected call to initdev_register() to be initdev_registered().
> > v5	Change bootdev_* to initdev_*.
> > v4	Use new hotplug synchronization infrastructure. Include Braille
> > 	console support.
> > v3.2	Use only a single new command line parameter by adding the possible
> > 	value "forever".  Add message specifying the parameter to modify to
> > 	increase the delay for console initialization
> > v3.1	Correct the abbreviation for milliseconds in
> > 	Documentation/kernel-parameters.txt to be "ms", not "mS". Thanks to
> > 	Peter Anvin for this.
> > v3	Increase the default delay to 1 second and add kernel command line
> > 	parameters to override the default delay. Thanks to David Brownell for
> > 	his helpful suggestions.
> > v2	Wait for the preferred console rather than any console. Make the
> > 	delay interval a tunable.
> > v1	Initial version
> > 
> > Signed-off-by: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
> > ---
> >  drivers/accessibility/braille/braille_console.c |    2 +
> >  kernel/printk.c                                 |   29 ++++++++++++++++++++++-
> >  2 files changed, 30 insertions(+), 1 deletions(-)
> 
> Is this diff complete?

To the best of my knowledge, yes, it is complete. What makes it look as though
it might not be?

> Stefan Richter

David VomLehn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
