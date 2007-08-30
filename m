From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 1/5] Net: ath5k, split hw into hw, phy and initvals
Date: Thu, 30 Aug 2007 08:38:49 -0400
Message-ID: <20070830123849.GB5140@tuxdriver.com>
References: <2713029743177393055@pripojeni.net> <20070828171034.GB29343@infradead.org> <40f31dec0708291850j2d35db6cu9de7c5f0a91e76f7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <40f31dec0708291850j2d35db6cu9de7c5f0a91e76f7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 04:50:01AM +0300, Nick Kossifidis wrote:
> 2007/8/28, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>:

> > ath5k_hw_phy.o should probably be ath5k_phy.o by conventions used by
> > most drivers and ath5k_hw_inivals.o mights aswell be something like
> > ath5k_init.o

> If you check out the code you'll see i'm using the same convention
> inside them, ath5k_hw* files contain hw related functions
> (ath5k_hw_<name>) while driver code has ath5k_<name>. Also ath5k_init
> is misleading, file acually includes initial register settings for

I have to agree w/ Christoph -- the extra "_hw" in the names is just
a bit unwieldy.

John

P.S.  "ath5k_initvals.c" seems acceptable to me.
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
