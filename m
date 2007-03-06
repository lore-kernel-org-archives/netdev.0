From: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Subject: Re: [2.6.21 patch] unconditionally enable SYSFS_DEPRECATED
Date: Tue, 6 Mar 2007 01:35:41 +0100
Message-ID: <20070306003541.GT3441@stusta.de>
References: <20070304220857.GH23311@waste.org> <1173051564.6131.13.camel@johannes.berg> <20070305002550.GI23311@waste.org> <20070305011729.GB7681@kroah.com> <20070305125950.GC26781@thunk.org> <20070305185813.GA31465@kroah.com> <20070305234052.GR3441@stusta.de> <20070306000722.GA11436@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070306000722.GA11436-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 04:07:22PM -0800, Greg KH wrote:
> On Tue, Mar 06, 2007 at 12:40:52AM +0100, Adrian Bunk wrote:
> > On Mon, Mar 05, 2007 at 10:58:13AM -0800, Greg KH wrote:
> > > 
> > > Ok, how about the following patch.  Is it acceptable to everyone?
> > > 
> > > thanks,
> > > 
> > > greg k-h
> > > 
> > > ---
> > >  init/Kconfig |   13 +++++++++++--
> > >  1 file changed, 11 insertions(+), 2 deletions(-)
> > > 
> > > --- gregkh-2.6.orig/init/Kconfig
> > > +++ gregkh-2.6/init/Kconfig
> > > @@ -290,8 +290,17 @@ config SYSFS_DEPRECATED
> > >  	  that belong to a class, back into the /sys/class heirachy, in
> > >  	  order to support older versions of udev.
> > >  
> > > -	  If you are using a distro that was released in 2006 or later,
> > > -	  it should be safe to say N here.
> > > +	  If you are using an OpenSuSE, Gentoo, Ubuntu, or Fedora
> > > +	  release from 2007 or later, it should be safe to say N here.
> > > +
> > > +	  If you are using Debian or other distros that are slow to
> > > +	  update HAL, please say Y here.
> > >...
> > 
> > The sane solution seems to be to enable SYSFS_DEPRECATED unconditionally 
> > for all users, and schedule it's removal for mid-2008 (or later).
> > 
> > 12 months after the first _release_ of a HAL that can live without seems 
> > to be the first time when we can consider getting rid of it, since all 
> > distributions with at least one release a year should ship it by then.
> > 
> > Currently, SYSFS_DEPRECATED is only a trap for users.
> 
> Huh?
> 
> No, again, I've been using this just fine for about 6 months now.
> 
> And what about all of the servers not using HAL/NetworkManager?

On a server, it shouldn't harm.

> And what about all of the embedded systems not using either?

If it was much code, I would have sent a patch that allowed disabling it 
if EMBEDDED=y.

> So to not allow this to be turned off by people who might want to (we
> want this for OpenSuSE 10.3, and Fedora 7 also will want this, as will
> other distros released this year), is pretty heavy-handed.
> 
> It also will work in OpenSuSE 10.2 which is already released, and I
> think Fedora 6, but I've only limited experience with these.
> 
> Oh, and Gentoo works just fine, and has been for the past 6 months.

For most people, it simply doesn't matter whether SYSFS_DEPRECATED is 
on or off.

But accidentally disabling SYSFS_DEPRECATED has proven to be a trap 
people sometimes fall into - and tracking them down to 
SYSFS_DEPRECATED=n sometimes takes some time.

> I would just prefer to come up with an acceptable set of wording that
> will work to properly warn people.
> 
> I proposed one such wording which some people took as a slam against
> Debian, which it really was not at all.
> 
> Does someone else want to propose some other wording instead?
> 
> thanks,
> 
> greg k-h

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
