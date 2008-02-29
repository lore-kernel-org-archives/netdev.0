From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Sat, 1 Mar 2008 00:13:11 +0100
Message-ID: <200803010013.11458.mb@bu3sch.de>
References: <20080228014125.GI3078@tuxdriver.com> <20080229162629.GB3234@tuxdriver.com> <1204302853.3938.40.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	gordonfarquharson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1204302853.3938.40.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 29 February 2008 17:34:13 Johannes Berg wrote:
> 
> On Fri, 2008-02-29 at 11:26 -0500, John W. Linville wrote:
> > On Fri, Feb 29, 2008 at 01:16:59PM +0100, Michael Buesch wrote:
> > 
> > > I'm wondering if we can't simply pass a commandline parameter to file2alias
> > > that tells it whether we are crosscompiling. It should simply omit the sanity check
> > 
> > Sounds reasonable to me.
> 
> In fact, file2alias shouldn't need a command line argument ...

Well, if...

> > > in that case. Is there any easy and reliable way to find out whether we
> > > are crosscompiling from a makefile (I don't know the makefile core that much)?
> > 
> > Non-empty CROSS_COMPILE definition?
> 
> ... it can just check whether CROSS_COMPILE is set in its environment.
> No?

Is that exported to the environment?

-- 
Greetings Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
