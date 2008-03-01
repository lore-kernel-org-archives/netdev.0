From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Sat, 1 Mar 2008 16:51:12 +0100
Message-ID: <200803011651.13652.mb@bu3sch.de>
References: <20080228014125.GI3078@tuxdriver.com> <20080229214240.GH3234@tuxdriver.com> <20080301130133.GA14250@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	gordonfarquharson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080301130133.GA14250-QabhHTsIXMSnlFQ6Q1D1Y0B+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 01 March 2008, Sam Ravnborg wrote:
> > This version seems to work, but it is a bit chatty when CROSS_COMPILE
> > is set and you build lots of modules...thoughts?
> 
> We cannot use CROSS_COMPILE to detect a cross build as CROSS_COMPILE
> is used used to select different gcc versions, cccache etc.
> The only relaiably way to detect a cross build is to check
> is ARCH != modified uname -m arch.
> So this check would have to be done in the top-level Makefile.
> 
> And that for shaving 6 bytes of a structure..

Wrong. For maintaining userspace ABI compatibility.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
