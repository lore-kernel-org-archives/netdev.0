From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: Distributed storage.
Date: Mon, 13 Aug 2007 12:22:55 +0200
Message-ID: <20070813102255.GN23758@kernel.dk>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130255.35828.phillips@phunq.net> <20070813100636.GL23758@kernel.dk> <200708130315.08382.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:1758 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937823AbXHMKW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 06:22:59 -0400
Content-Disposition: inline
In-Reply-To: <200708130315.08382.phillips@phunq.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13 2007, Daniel Phillips wrote:
> On Monday 13 August 2007 03:06, Jens Axboe wrote:
> > On Mon, Aug 13 2007, Daniel Phillips wrote:
> > > Of course not.  Nothing I said stops endio from being called in the
> > > usual way as well.  For this to work, endio just needs to know that
> > > one call means "end" and the other means "destroy", this is
> > > trivial.
> >
> > Sorry Daniel, but your suggestions would do nothing more than uglify
> > the code and design.
> 
> Pretty much exactly what was said about shrinking struct page, ask Bill.  
> The difference was, shrinking struct page actually mattered whereas 
> shrinking struct bio does not, and neither does expanding it by a few 
> bytes.

Lets back this up a bit - this whole thing began with you saying that
struct bio was bloated already, which I said wasn't true. You then
continued to hand wave your wave through various suggestions to trim the
obvious fat from that structure, none of which were nice or feasible.

I never compared the bio to struct page, I'd obviously agree that
shrinking struct page was a worthy goal and that it'd be ok to uglify
some code to do that. The same isn't true for struct bio.

And we can expand struct bio if we have to, naturally. And I've done it
before, which I wrote in the initial mail. I just don't want to do it
casually, then it WILL be bloated all of a sudden. Your laissez faire
attitude towards adding members to struct bio "oh I'll just add it and
someone less lazy than me will fix it up in the future" makes me happy
that you are not maintaining anything that I use.

I'll stop replying to your mails until something interesting surfaces.
I've already made my points clear about both the above and the
throttling. And I'd advise you to let Evgeniy take this forward, he
seems a lot more adept to actually getting CODE done and - at least from
my current and past perspective - is someone you can actually have a
fruitful conversation with.

-- 
Jens Axboe

