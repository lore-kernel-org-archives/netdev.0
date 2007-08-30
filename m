From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 5/5] Net: ath5k, kconfig changes
Date: Thu, 30 Aug 2007 13:35:54 +0100
Message-ID: <20070830123554.GA2176@infradead.org>
References: <2713029743177393055@pripojeni.net> <280951420471148977@pripojeni.net> <20070828171330.GD29343@infradead.org> <40f31dec0708291838p5d33eb34p3b4432d9d270841a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <40f31dec0708291838p5d33eb34p3b4432d9d270841a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 04:38:09AM +0300, Nick Kossifidis wrote:
> It saves big chunks of code (not only initial register settings
> arrays) and we'll extend it's use more inside ath5k_hw.c Trust me this
> is a very useful step, eg. check out descriptor processing / setup or
> PHY functions (calibrate/channel set etc). For example AR5210 mac chip
> only comes with RF5110 phy chip so we can get rid of RF5111/RF5112
> code, AR5211 comes with RF5111 so we can get rid of RF5110 and RF5112
> code and AR5212 comes with RF5111 or RF5112 so we get rid of RF5110.
> This thing also saves lots of checks during runtime (some of them
> happen verry frequently, eg. durring descriptor processing). Also most
> people will use 5212 code only, 5211 cards are on some old laptops and
> 5210, well i couldn't even find  a 5210 for actual testing :P

If you're doing these checks in a hotpath something is badly wrong with
your architecture.
