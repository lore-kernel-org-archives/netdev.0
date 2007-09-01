From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sat, 1 Sep 2007 23:52:25 +0200
Message-ID: <20070901215225.GM9260@stusta.de>
References: <200709010140.l811eq9H005896@cvs.openbsd.org> <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de> <f34ca13c0709011427u7a9cc97bp75c035afed3e5a63@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: "Constantine A. Murenin" <mureninc@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932792AbXIAVwk@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f34ca13c0709011427u7a9cc97bp75c035afed3e5a63@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 01, 2007 at 05:27:03PM -0400, Constantine A. Murenin wrote:
> On 01/09/07, Adrian Bunk <bunk@kernel.org> wrote:
> > On Sat, Sep 01, 2007 at 01:37:18PM -0400, Constantine A. Murenin wrote:
> > > On 01/09/07, Jeff Garzik <jeff@garzik.org> wrote:
> > > > Constantine A. Murenin wrote:
> > > > > This will hopefully help diminish certain myths about the code licensing.
> > > >
> > > > What myth?  The myth that Theo understands dual licensing?
> > >
> > > Reyk's code was never dual licensed, so it's not like it even matters
> > > to the original dispute.
> >
> > It's no longer dual licenced in the FreeBSD tree because the FreeBSD
> > people removed the GPL choice of the dual licenced code 3 months ago.
> 
> FreeBSD doesn't have Reyk's ath(4) HAL, which OpenHAL is based on.
> 
> FreeBSD has a driver written by Sam, and a binary-only HAL, also written by Sam.
> 
> > So all of Theo's accusations of people breaking the law by making this
> > dual licenced code GPL-only apply as well to the FreeBSD people...
> 
> How? FreeBSD doesn't have Reyk's ath(4) HAL from OpenBSD, so there are
> no possible licensing accusations and violations.

OK, I begin to understand this, there seem to be three different types 
of files changed by Jiri's patch:
1. dual licenced files planned to make GPL-only
2. previously dual licenced files with a too recent version used planned 
   to make GPL-only
3. never dual licenced files planned to make GPL-only

For files under 1. and 2. Reyk did contribute to dual licenced code 
without touching the licence, but I missed that there's also code unter 3.

So there is a problem, but not with the code under 1. (unless you plan 
to change the semantics of the word "alternatively"), the problem is 
with some headers under 2. plus the code under 3.

It's funny how Theo missed the part of Jiri's patch that actually is a 
copyright violation and instead complains about the part that is OK...

> > > That said, I don't see what exact wording you consider inaccurate.
> >
> > Both the FreeBSD and Linux people draw the logical conclusion that this
> > "Alternatively" means everyone can always choose to remove one of the
> > two choices alternatively offered.
> >
> > According to Theo, that is "breaking the law"...
> 
> FreeBSD's ath(4) code, both the driver and the HAL, is entirely
> written by Sam Leffler, who can licence it in whichever way he seems
> reasonable. The driver part of Sam's code is also present in OpenBSD,
> but the HALs in OpenBSD and FreeBSD are entirely different.

Sam also changed the licence of a file additionally containing an
  Copyright (c) 2004 Video54 Technologies, Inc.

> C.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
