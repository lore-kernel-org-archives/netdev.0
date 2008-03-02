From: Adrian Bunk <bunk@kernel.org>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Sun, 2 Mar 2008 17:44:29 +0200
Message-ID: <20080302154429.GK25835@cs181133002.pp.htv.fi>
References: <20080228014125.GI3078@tuxdriver.com> <97a0a9ac0802281321h6f302865j38a55c6f761dc14b@mail.gmail.com> <20080228.133008.228590007.davem@davemloft.net> <200802291316.59738.mb@bu3sch.de> <20080229162629.GB3234@tuxdriver.com> <1204302853.3938.40.camel@johannes.berg> <20080229191058.GD3234@tuxdriver.com> <20080229214240.GH3234@tuxdriver.com> <20080301130133.GA14250@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Michael Buesch <mb@bu3sch.de>,
	David Miller <davem@davemloft.net>,
	gordonfarquharson@gmail.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:53255 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215AbYCBPqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2008 10:46:00 -0500
Content-Disposition: inline
In-Reply-To: <20080301130133.GA14250@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 01, 2008 at 02:01:33PM +0100, Sam Ravnborg wrote:
> On Fri, Feb 29, 2008 at 04:42:40PM -0500, John W. Linville wrote:
> > On Fri, Feb 29, 2008 at 02:10:58PM -0500, John W. Linville wrote:
> > > On Fri, Feb 29, 2008 at 05:34:13PM +0100, Johannes Berg wrote:
> > > > 
> > > > On Fri, 2008-02-29 at 11:26 -0500, John W. Linville wrote:
> > > > > On Fri, Feb 29, 2008 at 01:16:59PM +0100, Michael Buesch wrote:
> > > > > 
> > > > > > I'm wondering if we can't simply pass a commandline parameter to file2alias
> > > > > > that tells it whether we are crosscompiling. It should simply omit the sanity check
> > > > > 
> > > > > Sounds reasonable to me.
> > > > 
> > > > In fact, file2alias shouldn't need a command line argument ...
> > > > 
> > > > > > in that case. Is there any easy and reliable way to find out whether we
> > > > > > are crosscompiling from a makefile (I don't know the makefile core that much)?
> > > > > 
> > > > > Non-empty CROSS_COMPILE definition?
> > > > 
> > > > ... it can just check whether CROSS_COMPILE is set in its environment.
> > > > No?
> > > 
> > > Not a bad idea...something like this?
> > 
> > That version didn't work -- it seems CROSS_COMPILE is always set,
> > even if it is empty.
> > 
> > This version seems to work, but it is a bit chatty when CROSS_COMPILE
> > is set and you build lots of modules...thoughts?
> 
> We cannot use CROSS_COMPILE to detect a cross build as CROSS_COMPILE
> is used used to select different gcc versions, cccache etc.
> The only relaiably way to detect a cross build is to check
> is ARCH != modified uname -m arch.
> So this check would have to be done in the top-level Makefile.
> 
> And that for shaving 6 bytes of a structure..

I remember two other occassions where this file2alias mess has bitten us 
recently.

I don't mind that much how it gets fixed, but the current status quo of 
having this kind of problems again and again is simply not acceptable.

> 	Sam

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

