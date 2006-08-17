From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: 802.11 headers
Date: Thu, 17 Aug 2006 08:43:33 -0400
Message-ID: <20060817124327.GA17771@tuxdriver.com>
References: <1155800899.3653.13.camel@ux156> <20060817143443.77ede2e5@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	Jouni Malinen <jkm@devicescape.com>,
	David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:24078 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932468AbWHQMow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 08:44:52 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060817143443.77ede2e5@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2006 at 02:34:43PM +0200, Jiri Benc wrote:
> On Thu, 17 Aug 2006 09:48:19 +0200, Johannes Berg wrote:

> > Or put another way, my suggestions:
> >  - put all in-kernel API (for drivers) into net/d80211.h
> >  - put stuff defined in the IEEE 802.11 specification series into
> >    linux/ieee80211.h, make user-visible (headers-y in Kbuild!). This
> >    serves just as a reference. It's not really necessary that the kernel
> >    ships this, but we need it in the kernel and probably won't be
> >    pulling it from some other source. Besides, I wouldn't know where
> >    else to maintain it.
> >  - radiotap simply moves to linux/ and gets to be userland-visible. Of
> >    course, d80211 should actually start using it too ;)
> >  - all the other userland stuff seems to be configuration related and
> >    hence moves over to linux/nl80211.h
> > 
> > Comments?
> 
> I like this proposal.

I second that.

John
-- 
John W. Linville
linville@tuxdriver.com
