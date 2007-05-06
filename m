From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Merging SSB upstream
Date: Sun, 6 May 2007 03:03:17 +0200
Message-ID: <200705060303.17594.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

So, now that mac80211 is merged upstream, I think it's
time to merge SSB and the b44-ssb port upstream.
Note that bcm43xx-mac80211 is _not_ ready for upstream, yet.

What do you think? I'd like to merge ssb as-is, although
the embedded-device parts are not quite finished, yet.
But they don't interfere with the non-embedded parts used
by b44 and the bcm43xx PCI cards.
So we _could_ remove the ssb-mips code, but I don't like to
do that for better maintainability. It doesn't hurt anyone IMO.

Some opinions?

-- 
Greetings Michael.
