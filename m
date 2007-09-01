From: "Constantine A. Murenin" <mureninc@gmail.com>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sat, 1 Sep 2007 19:29:39 -0400
Message-ID: <f34ca13c0709011629g1f16508cic7c31c3d20a57dae@mail.gmail.com>
References: <200709010140.l811eq9H005896@cvs.openbsd.org>
	 <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
	 <46D99FB7.6030505@garzik.org>
	 <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com>
	 <20070901205457.GK9260@stusta.de>
	 <f34ca13c0709011427u7a9cc97bp75c035afed3e5a63@mail.gmail.com>
	 <20070901215225.GM9260@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"Jiri Slaby" <jirislaby@gmail.com>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:31636 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757535AbXIAX3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 19:29:40 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1143277wxd
        for <netdev@vger.kernel.org>; Sat, 01 Sep 2007 16:29:39 -0700 (PDT)
In-Reply-To: <20070901215225.GM9260@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/07, Adrian Bunk <bunk@kernel.org> wrote:
> On Sat, Sep 01, 2007 at 05:27:03PM -0400, Constantine A. Murenin wrote:
> > On 01/09/07, Adrian Bunk <bunk@kernel.org> wrote:
> > > On Sat, Sep 01, 2007 at 01:37:18PM -0400, Constantine A. Murenin wrote:
> > > > On 01/09/07, Jeff Garzik <jeff@garzik.org> wrote:
> > > > > Constantine A. Murenin wrote:
> > > > > > This will hopefully help diminish certain myths about the code licensing.
> > > > >
> > > > > What myth?  The myth that Theo understands dual licensing?
> > > >
> > > > Reyk's code was never dual licensed, so it's not like it even matters
> > > > to the original dispute.
> > >
> > > It's no longer dual licenced in the FreeBSD tree because the FreeBSD
> > > people removed the GPL choice of the dual licenced code 3 months ago.
> >
> > FreeBSD doesn't have Reyk's ath(4) HAL, which OpenHAL is based on.
> >
> > FreeBSD has a driver written by Sam, and a binary-only HAL, also written by Sam.
> >
> > > So all of Theo's accusations of people breaking the law by making this
> > > dual licenced code GPL-only apply as well to the FreeBSD people...
> >
> > How? FreeBSD doesn't have Reyk's ath(4) HAL from OpenBSD, so there are
> > no possible licensing accusations and violations.
>
> OK, I begin to understand this, there seem to be three different types
> of files changed by Jiri's patch:
> 1. dual licenced files planned to make GPL-only
> 2. previously dual licenced files with a too recent version used planned
>    to make GPL-only
> 3. never dual licenced files planned to make GPL-only
>
> For files under 1. and 2. Reyk did contribute to dual licenced code
> without touching the licence, but I missed that there's also code unter 3.
>
> So there is a problem, but not with the code under 1. (unless you plan
> to change the semantics of the word "alternatively"), the problem is
> with some headers under 2. plus the code under 3.
>
> It's funny how Theo missed the part of Jiri's patch that actually is a
> copyright violation and instead complains about the part that is OK...

I'm not sure how you conclude that Theo missed the relevant parts --
there were many messages posted to misc@openbsd.org mailing list and
to The OpenBSD Journal in the last few days, and to me it appears as
all of the problems were discussed ad nauseam.

After the obvious copyright violations were addressed, I think the
problem started being an ethical one.

As a free software user and developer, the question I have is how come
the Linux community feels that they can take the BSD code that was
reverse-engineered at OpenBSD, and put a more restrictive licence onto
it, such that there will be no possibility of the changes going back
to OpenBSD, given that the main work on the code has happened at
OpenBSD? (Obviously, such a scenario it is permitted by the licence,
but my question is an ethical one -- after all, most components of
OpenHAL were specifically based on the OpenBSD's ath(4) HAL code.)

You can see that Christoph Hellwig agrees with this ethical problem,
as in the message below.

C.


On 28/08/07, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Aug 28, 2007 at 12:00:50PM -0400, Jiri Slaby wrote:
> > ath5k, license is GPLv2
> >
> > The files are available only under GPLv2 since now.
>
> Is this really a good idea?  Most of the reverse-engineering was
> done by the OpenBSD folks, and it would certainly be helpful to
> work together with them on new hardware revisions, etc..

( from http://lkml.org/lkml/2007/8/28/178 )
