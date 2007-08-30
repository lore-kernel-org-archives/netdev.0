From: "Nick Kossifidis" <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] Net: ath5k, split hw into hw, phy and initvals
Date: Thu, 30 Aug 2007 04:50:01 +0300
Message-ID: <40f31dec0708291850j2d35db6cu9de7c5f0a91e76f7@mail.gmail.com>
References: <2713029743177393055@pripojeni.net>
	 <20070828171034.GB29343@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Jiri Slaby" <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Christoph Hellwig" <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070828171034.GB29343-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2007/8/28, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>:
> On Tue, Aug 28, 2007 at 11:58:52AM -0400, Jiri Slaby wrote:
> > -ath5k-objs           = ath5k_base.o ath5k_hw.o ath5k_regdom.o
> > +ath5k-objs           = ath5k_base.o ath5k_hw.o ath5k_regdom.o \
> > +                       ath5k_hw_phy.o ath5k_hw_inivals.o
>
> And while I'm at nitpicking :)
>
> ath5k_hw_phy.o should probably be ath5k_phy.o by conventions used by
> most drivers and ath5k_hw_inivals.o mights aswell be something like
> ath5k_init.o
>

If you check out the code you'll see i'm using the same convention
inside them, ath5k_hw* files contain hw related functions
(ath5k_hw_<name>) while driver code has ath5k_<name>. Also ath5k_init
is misleading, file acually includes initial register settings for
various chips and the functions to apply them on hw, not the
initialization/attach/wakeup etc routines (that can be found  in
ath5k_hw.c), that's why it's inivals, i couldn't find a more
appropriate name.


-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
