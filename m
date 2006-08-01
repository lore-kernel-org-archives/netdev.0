From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Tue, 1 Aug 2006 21:13:41 +0200
Message-ID: <20060801191341.GA15662@p15091797.pureserver.info>
References: <200607270037.22384.flamingice@sourmilk.net> <20060731203113.GG10138@tuxdriver.com> <200607311351.35757.flamingice@sourmilk.net> <20060801095650.GA6831@infradead.org> <20060801122142.GB29208@tuxdriver.com> <20060801155837.4c3210aa@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:31206 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751813AbWHATNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 15:13:41 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060801155837.4c3210aa@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-08-01 15:58 Jiri Benc wrote:

> > pointing non-migrated drivers (ipw2[12]00, zd1211rw) at the old
> > code,
> 
> Yes. Rather than moving, zd1211 should be ported to d80211 - this will
> also allow using of more advanced features of the hw.

I have currently no idea, when this will happen. Currently we are
still working on the basic plumbing of the driver.

However I would support the descape-preparing clean-up, if
pointless renaming is minimized. In the ideal case only header
includes should be changed. I would support a split between
protocol related headers and stack-related stuff.

Cheers,

Uli

-- 
Uli Kunitz
