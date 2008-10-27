From: Pavel Machek <pavel@suse.cz>
Subject: Re: [PATCH] wireless: fix regression caused by regulatory config
	option
Date: Mon, 27 Oct 2008 21:42:50 +0100
Message-ID: <20081027204249.GA1620@ucw.cz>
References: <20081026103024.2712ddc9@infradead.org> <20081026200939.GC12648@tuxdriver.com> <20081026131818.7517c103@infradead.org> <1225052537.3746.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, rodriguez@atheros.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:57999 "EHLO UNKNOWN"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751947AbYJ0UnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 16:43:10 -0400
Content-Disposition: inline
In-Reply-To: <1225052537.3746.5.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun 2008-10-26 21:22:16, Johannes Berg wrote:
> On Sun, 2008-10-26 at 13:18 -0700, Arjan van de Ven wrote:
> 
> > > Is it common practice to have compatibility options default to
> > > "y"?  I'm not saying it shouldn't be, just wondering if it has been
> > > traditionally?
> > 
> > yes
> > 
> > default should be "keep working as before"
> > 
> > it's not always nice, especially if you're trying to get rid of some
> > nasty stuff, but think of it this way: you should be able to use a
> > new kernel on an existing distro, at least for a reasonable type of
> > distro (eg something shipped in, say, the last 2 years). In this case:
> > even Fedora 10 is not likely to work!
> 
> Well, actually, it _ought_ to work fine, with a smaller set of channels,

Really? It will still break if your AP uses one of those channels, right?


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
