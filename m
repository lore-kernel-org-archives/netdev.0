From: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Subject: Re: [PATCH 1/1] posix clocks: introduce syscall for clock tuning.
Date: Mon, 23 Aug 2010 07:43:30 -0600
Message-ID: <20100823134330.GM12892@parisc-linux.org>
References: <cover.1282550649.git.richard.cochran@omicron.at> <e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran@omicron.at> <201008231457.26690.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201008231457.26690.arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 23, 2010 at 02:57:26PM +0200, Arnd Bergmann wrote:
> > +static inline int common_clock_adj(const clockid_t which_clock, int ppb,
> > +				   struct timespec *tp)
> > +{
> > +	return -EOPNOTSUPP;
> > +}
> > +
> >  static int no_timer_create(struct k_itimer *new_timer)
> >  {
> >  	return -EOPNOTSUPP;
> 
> So we already return -EOPNOTSUPP in some cases? The man page does not document this.
> I wonder if we should change that to -EINVAL as well.

ENOTTY is the usual errno for "inappropriate ioctl for device".  Due to
the way this patch has been chopped up, I can't tell if that's what is
intended here.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
