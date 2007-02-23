From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [tipc-discussion] [RFC: 2.6 patch] net/tipc/: possible cleanups
Date: Fri, 23 Feb 2007 19:06:12 +0100
Message-ID: <20070223180612.GE12392@stusta.de>
References: <20070124225850.GU17836@stusta.de> <45B8D5E8.1090308@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: per.liden@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:42437 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932488AbXBWSGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 13:06:15 -0500
Content-Disposition: inline
In-Reply-To: <45B8D5E8.1090308@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 25, 2007 at 04:08:08PM +0000, Jon Maloy wrote:
> Adrian Bunk wrote:
> 
> >This patch contains the following possible cleanups:
> >- make needlessly global functions static
> >- #if 0 unused functions
> > 
> >
> Thanks. I think most of those were due for our next release, anyway. But 
> we'll
> get it in, one way or another. 
> 
> >- remove all EXPORT_SYMBOL's
> >
> >My impression is that most of this might have users that are not yet 
> >submitted for inclusion in the kernel - one year after TIPC was merged.
> > 
> >
> Not quite. The exported symbols belong to a public API for driver 
> programmers.
> We know about several users of this API, and there will be more, but I 
> don't think
> any of them are aspiring to have their code be included in the kernel.
>...

Why not?

The goal is to get as many drivers as possible included in the kernel.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

