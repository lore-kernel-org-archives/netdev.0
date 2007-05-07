From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] Add rtl8187 wireless driver
Date: Mon, 07 May 2007 01:39:50 -0700 (PDT)
Message-ID: <20070507.013950.39156872.davem@davemloft.net>
References: <20070507073636.4232.93444.stgit@panda.sourmilk.net>
	<200705070346.17868.flamingice@sourmilk.net>
	<20070507081531.GA28498@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070507081531.GA28498-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date: Mon, 7 May 2007 09:15:31 +0100

> On Mon, May 07, 2007 at 03:46:17AM -0400, Michael Wu wrote:
> > This patch adds a mac80211 based wireless driver for the rtl8187 USB
> > wireless card.
> > 
> > Signed-off-by: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
> > ---
> > 
> >  MAINTAINERS                                        |   10 
> >  drivers/net/wireless/Kconfig                       |    2 
> >  drivers/net/wireless/Makefile                      |    3 
> >  drivers/net/wireless/mac80211/Kconfig              |    1 
> >  drivers/net/wireless/mac80211/Makefile             |    1 
> >  drivers/net/wireless/mac80211/rtl818x/Kconfig      |   16 
> >  drivers/net/wireless/mac80211/rtl818x/Makefile     |    2 
> >  drivers/net/wireless/mac80211/rtl818x/rtl8187.h    |  125 +++
> >
> 
> Driver shouldn't be in another useless sub-hiearchay just because
> of some common code they use.

Agreed.
