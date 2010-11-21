From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 00/62] drivers/net: Use static const
Date: Sat, 20 Nov 2010 20:50:59 -0800 (PST)
Message-ID: <20101120.205059.193725921.davem@davemloft.net>
References: <cover.1290305773.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
To: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <cover.1290305773.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date: Sat, 20 Nov 2010 18:38:01 -0800

> Using static const generally increases object text and decreases data size.
> It also generally decreases overall object size.

Joe, I'm going to be frank and say that I'm not going to review and
apply such a large chunk of networking patches.

Seperation is cool, splitting up patches is cool to make review
perhaps easier and more distributed.

But in the end _I_ have to purge through these things and submitting
so many patches at a time, multiple times per release cycle, abuses me
as a resource.

Yes, Linus has to deal with perhaps a hundred patches, or more, at a
time from Andrew Morton during the merge window.  But he has to do
that _ONE_ time each release.  You crap large sets of patches on me
multiple times per release cycle.

This cannot continue, my sanity depends upon it.

You therefore cannot funnel 40, 50, 60, or more patches at me at a
time, multiple times per release.  It severely negatively effects my
mood, because it makes me feel like me head is below water again
_RIGHT_ after I've worked all damn week to finally made the networking
patch backlog sane again.

You also make this more difficult for me by not using GIT.  Even
with patchwork helping me significantly, it's still a lot of work
to apply large sets of patches.  If I had to take in John Linville's
wireless stuff without GIT I'd be banging my head on a wall.

And these incessant huge patch bombs also take time away from me for
the things I'd like to at least occiasionally work on that involve
more intellect than monkeying around with such mindless patches.

Thanks for your understanding.  Feel free to submit this stuff in
smaller chunks, say ~10 patches at a time.
