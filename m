From: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Fri, 23 Jan 2009 18:09:04 +0100
Message-ID: <20090123170904.GA26083@uranus.ravnborg.org>
References: <1232223441.3966.22.camel@localhost.localdomain> <1232228261.27094.0.camel@macbook.infradead.org> <20090117221932.GA4956@uranus.ravnborg.org> <49725B1E.604@kernel.org> <1232498319.3123.34.camel@localhost.localdomain> <1232726359.3504.18.camel@localhost.localdomain> <1232726658.3504.22.camel@localhost.localdomain> <alpine.LSU.2.00.0901231710350.15413@fbirervta.pbzchgretzou.qr> <20090123162153.GA25766@uranus.ravnborg.org> <1232728304.3504.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>,
	"H. Peter Anvin" <hpa-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, x86 maintainers <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, tiwai-l3A5Bk7waGM@public.gmane.org,
	mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1232728304.3504.28.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 23, 2009 at 10:01:44PM +0530, Jaswinder Singh Rajput wrote:
> On Fri, 2009-01-23 at 17:21 +0100, Sam Ravnborg wrote:
> > On Fri, Jan 23, 2009 at 05:11:13PM +0100, Jan Engelhardt wrote:
> > > 
> > > On Friday 2009-01-23 17:04, Jaswinder Singh Rajput wrote:
> > > >> > diff --git a/include/linux/dvb/audio.h b/include/linux/dvb/audio.h
> > > >> > index 89412e1..758a48c 100644
> > > >> > --- a/include/linux/dvb/audio.h
> > > >> > +++ b/include/linux/dvb/audio.h
> > > >> > @@ -24,9 +24,8 @@
> > > >> >  #ifndef _DVBAUDIO_H_
> > > >> >  #define _DVBAUDIO_H_
> > > >> >  
> > > >> > -#ifdef __KERNEL__
> > > >> >  #include <linux/types.h>
> > > >> > -#else
> > > >> > +#ifndef __KERNEL__
> > > >> >  #include <stdint.h>
> > > >> >  #endif
> > > >> > 
> > > >> 
> > > >> It seems one have objection for this. So I will again insert this in my
> > > >> new patchset.
> > > >> 
> > > >
> > > >oops, s/seems one/seems no one ;-)
> > > 
> > > I had an objection as previously stated -- namely that
> > > <stdint.h> should be included to remain friendly to C++0x
> > > programs which should use <cstdint> instead. Forcing
> > > stdint.h is therefore not nice.
> > 
> > This is fully agreed.
> > Jaswinder - can I ask you to do this change (remove of the stdint.h include)
> > in a follow-up patch. It is two independent changes.
> > You original patch is fine as is.
> 
> So is this OK:
> 
> -#ifdef __KERNEL__
>  #include <linux/types.h>
> -#else
> -#include <stdint.h>
> -#endif

That was what I expected the final change to look like.
If you want then combine it in one patch.

	Sam
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
