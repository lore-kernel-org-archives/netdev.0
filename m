From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Tue, 1 Aug 2006 13:11:04 -0400
Message-ID: <20060801171058.GH29208@tuxdriver.com>
References: <200607270037.22384.flamingice@sourmilk.net> <20060731203113.GG10138@tuxdriver.com> <200607311351.35757.flamingice@sourmilk.net> <20060801095650.GA6831@infradead.org> <20060801122142.GB29208@tuxdriver.com> <20060801155837.4c3210aa@griffin.suse.cz> <20060801140720.GC29208@tuxdriver.com> <a32f33a40608010725m247304a5vda49207c8f36cf62@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, Christoph Hellwig <hch@infradead.org>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2062 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932544AbWHARL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 13:11:29 -0400
To: Ivo Van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <a32f33a40608010725m247304a5vda49207c8f36cf62@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 04:25:05PM +0200, Ivo Van Doorn wrote:
> Hi,
> 
> >> Do you have a plan when you will merge rt2x00 patches so I can apply
> >> Michael's renaming patch(es) without risk of conflicts?
> >
> >Working on it ~now.  I hit a snag in that Ivo's patches seem to rely on
> >his radio button patch, which I had ignored until now.  I'll probably
> >pull that in this morning (or figure-out how to not need it) and get
> >something pushed to wireless-dev sometime today.
> 
> Ehm, that should not have happened. The rt2x00 version I had send as patches
> had the radio button integrated as they had been in wireless-dev already.
> The patch to convert it to the rfkill driver is one of the patches
> I'll send later.

The rfkill stuff seems to be behind a CONFIG_RT2X00_BUTTON define,
which keys off some driver-specific Kconfig stuff.  They were
getting turned-on by default w/ 'allmodconfig' and 'allyesconfig'.
Turning them off in .config lets them compile.

In general, I'd prefer not to have Kconfig-settable options that
don't compile.  But in this case I guess we'll just live with it.
After all, it is a development tree... :-)

John
-- 
John W. Linville
linville@tuxdriver.com
