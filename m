From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Thu, 15 Jan 2009 11:54:53 +0100
Message-ID: <20090115105453.GF29296@elte.hu>
References: <1231836016.3212.41.camel@jaswinder.satnam> <20090113124921.GA30400@elte.hu> <20090114154057.GC32082@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:49888 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763706AbZAOKzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 05:55:21 -0500
Content-Disposition: inline
In-Reply-To: <20090114154057.GC32082@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Sam Ravnborg <sam@ravnborg.org> wrote:

> On Tue, Jan 13, 2009 at 01:49:21PM +0100, Ingo Molnar wrote:
> > 
> > * Jaswinder Singh Rajput <jaswinder@infradead.org> wrote:
> > 
> > > Hello Ingo,
> > > 
> > > Please pull these patches. Earlier I also floated these patches so that 
> > > I can get some feedback.
> > 
> > Sam, Andrew, David, what's your workflow preference for these bits?
> > 
> > While they are oneliners and i could create a separate branch for these 
> > and pull Jaswinder's tree (and do build coverage to make sure there's no 
> > surprised on any arch), it's really up to the maintainers of these files 
> > to decide on the workflow.
> > 
> > I'd lean towards doing this via the individual maintainers and/or -mm, but 
> > no strong feelings ...
> 
> As they are one-liners for the most part I am fine with you handling
> them in a eparate branch.
> 
> It is far better than I queue them up for at least two weeks before I
> can give the kernel a bit of attention again.
> 
> Obviously it would be better if the Maintainers took them but history 
> tells us we cannot rely on that for all areas.

i dont think maintainers are bad at doing this - the problem and overhead 
is on the submission side: the logistics of spreading dozens of very small 
commits out to dozens of maintainers - each of who prefers a different 
submission channel.

We have no automation for that (to make sure there's guaranteed progress 
and to make sure there's no lost patch) and hence it's simply neither 
efficient nor reliable to do it.

These particular commits seem rather uncontroversial - and they are not 
part of some bigger facility so they are individually revertable as well. 
Worst-case they break the build somewhere or cause a raised maintainer 
eyebrow - we'll try to make sure that no such thing happens on a larger 
scale.

	Ingo
