From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Thu, 20 Sep 2007 09:47:30 -0400
Message-ID: <20070920134730.GC6748@tuxdriver.com>
References: <20070919181005.GB5483@tuxdriver.com> <46F19DD0.2050605@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46F19DD0.2050605-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 11:08:16PM +0100, Daniel Drake wrote:

> I would like to this until 2.6.25 until I have had time to clear up some 
> final issues and do more testing myself of zd1211rw-mac80211. I also 
> think we need to discuss the rename...

Renames being what they are, I was hoping to avoid a "bikeshed"
discussion about the choice of names.  My main point was to get it
into the tree with a unique and manageable name.  I'm sure we could
still rename it again before 2.6.24 ships or even later.

I know that you will argue that a rename is unnecessary if we
simply port the existing driver to mac80211, which is certainly true.
I just wonder if that is the least bumpy solution for users.  At least
with a new driver, if something doesn't work then the old driver is
still there as a fallback.  Plus you can avoid some confusion with
old howtos and such on the web referring to an old driver instead
of the new one, etc.  Maybe that isn't a huge issue in this case,
but I wouldn't underestimate the possible confusion.

> (just to clarify to others: this is the first I heard of this merge 
> before John posted it).

Yes, sorry...permission, forgiveness...forgive? :-)

> John, thanks a lot for your efforts, I hope you don't mind waiting one 
> extra release cycle for me to sort a few things out.

Well, obviously I would like to get it out now.  The longer we are
without a mac80211-based driver for zd1211 hardware then the longer
we must maintain the softmac component (or at least take bug reports
for it).

If you are determined not to have it in 2.6.24 then I will relent.
I will also suggest that Larry start sending any softmac bugs to
you... :-)

If we will be having a port rather than a new driver, how soon after
2.6.24-rc1 closes can we queue the port for 2.6.25?  I think it
should be almost immediately, to ensure maximum test exposure and to
"seal the deal".  What do you think?

Thanks,

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
