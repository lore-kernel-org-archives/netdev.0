From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Wed, 19 Jun 2013 07:27:31 -0700
Message-ID: <20130619142731.GA7979@kroah.com>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
 <20130523022327.GB6159@kroah.com>
 <519D8876.9050405@suse.com>
 <51BF6BFF.7050705@suse.cz>
 <51C1595D.60706@ti.com>
 <51C159F8.8090604@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tomi Valkeinen <tomi.valkeinen-l0cyMroinI0@public.gmane.org>,
	Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>, jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Alexander Shishkin <alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Tobias Schandinat <FlorianSchandinat-Mmb7MZpHnFY@public.gmane.org>,
	linux-geode-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	"Keller, Jacob E" <jacob.e.keller-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>
To: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51C159F8.8090604-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 19, 2013 at 09:12:56AM +0200, Jiri Slaby wrote:
> On 06/19/2013 09:10 AM, Tomi Valkeinen wrote:
> > On 17/06/13 23:05, Jiri Slaby wrote:
> > 
> >> The last point I inclined to the Greg's argument to remove the
> >> EXPERT dependency.
> >> 
> >> So currently I have what is attached... Comments?
> > 
> > The patch looks a bit odd with the USB_CHIPIDEA_IMX parts. You're
> > not adding COMPILE_TEST there, but you're adding a totally new
> > config option, and also changing the Makefile.
> 
> Look:
> 
> +config USB_CHIPIDEA_IMX
> +       bool "ChipIdea IMX support"
> +       depends on OF_DEVICE && (ARM || COMPILE_TEST)

Ah, what about all of the chipidea chips on x86 boxes (yes, they are
rare, but they are present, so you can't just turn them off for that
whole platform here.

I'd leave chipidea alone, it's getting more prelevant, not on a desktop
or server, but in SoC systems, which is x86 for a lot of devices.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
