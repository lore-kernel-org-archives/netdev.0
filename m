From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 5/5] Net: ath5k, kconfig changes
Date: Thu, 30 Aug 2007 08:36:09 -0400
Message-ID: <20070830123609.GA5140@tuxdriver.com>
References: <2713029743177393055@pripojeni.net> <280951420471148977@pripojeni.net> <20070828171330.GD29343@infradead.org> <40f31dec0708291838p5d33eb34p3b4432d9d270841a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <40f31dec0708291838p5d33eb34p3b4432d9d270841a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 04:38:09AM +0300, Nick Kossifidis wrote:
> 2007/8/28, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>:

> > Also this whole patch seems rather pointless.  It saves only
> > very little and turns the driver into a complete ifdef maze.

> Also most
> people will use 5212 code only, 5211 cards are on some old laptops and
> 5210, well i couldn't even find  a 5210 for actual testing :P

FWIW, I'd bet dollars to donuts that distros will enable them all
together.

Is saving code space the only reason to turn these off?  How much
space do you save?

Is there some way you can isolate and/or limit the number of ifdef
blocks further?  If so, we might consider a version of this patch
that depends on EMBEDDED or somesuch...?

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
