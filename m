From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: Merging SSB upstream
Date: Sat, 5 May 2007 22:00:51 -0400
Message-ID: <20070506020051.GA30917@tuxdriver.com>
References: <200705060303.17594.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200705060303.17594.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 06, 2007 at 03:03:17AM +0200, Michael Buesch wrote:
> So, now that mac80211 is merged upstream, I think it's
> time to merge SSB and the b44-ssb port upstream.
> Note that bcm43xx-mac80211 is _not_ ready for upstream, yet.
 
ACK, unfortunately.

> What do you think? I'd like to merge ssb as-is, although
> the embedded-device parts are not quite finished, yet.
> But they don't interfere with the non-embedded parts used
> by b44 and the bcm43xx PCI cards.

How much testing have you (and others) done w/ b44?  I had to remove
the b44 ssb changes from fedora because a) users reported problems;
and b) I was more worried about wireless than b44+ssb. (sorry!)

So, has anyone been using b44 in -mm?

> So we _could_ remove the ssb-mips code, but I don't like to
> do that for better maintainability. It doesn't hurt anyone IMO.

I guess I don't see a problem w/ merging the mips part, as long as the
b44 part has been thoroughly tested.  I wonder if Ralf has an opinion?

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
