From: Marc MERLIN <marc@merlins.org>
Subject: Re: Getting the correct asix AX88178 usb gige driver in mainline?
Date: Wed, 6 Jul 2011 14:08:57 -0700
Message-ID: <20110706210857.GH22090@merlins.org>
References: <20110629033025.GA32153@merlins.org> <201107062209.05794.arnd@arndb.de> <20110706201751.GG22090@merlins.org> <201107062235.01437.arnd@arndb.de> <20110629033025.GA32153@merlins.org> <20110706172538.GI18238@merlins.org> <201107062209.05794.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, greg@kroah.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:54751 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756295Ab1GFVJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 17:09:03 -0400
Content-Disposition: inline
In-Reply-To: <201107062235.01437.arnd@arndb.de> <201107062209.05794.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2011 at 10:09:05PM +0200, Arnd Bergmann wrote:
> > Here are the details. If somehow their driver could be integrated in
> > mainline by putting the relevant bits in the current driver, that would be
> > fantastic :)
> > (obviously it would have been better if they had done that themselves to
> > start with, no idea why they didn't).
> > 
> 
> Hi Marc,
> 
> I've taken a look at the driver you linked to and compared it to the
> version that was closest at the time.
> 
> This is similar to the patch they must have had at some point. I would guess
> that the answer is somewhere in there. It's quite different to the much
> cleaner patch 933a27d39e "USB: asix - Add AX88178 support and many other
> changes", which was merged later with a similar intention.

(...)

> The patch I mentioned was merged back in 2006, for 2.6.19. Either that
> patch was never complete and is missing support for your hardware, or
> it broke since then. You should probably try an old kernel to see if it's
> actually a regression.

Thanks for the details Arnd, I'll see if I can boot 2.6.19 on that laptop
and report back.

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
