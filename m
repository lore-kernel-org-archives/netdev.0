From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Getting the correct asix AX88178 usb gige driver in mainline?
Date: Thu, 7 Jul 2011 14:55:36 +0200
Message-ID: <201107071455.36975.arnd@arndb.de>
References: <20110629033025.GA32153@merlins.org> <201107062209.05794.arnd@arndb.de> <20110706210857.GH22090@merlins.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greg@kroah.com
To: Marc MERLIN <marc@merlins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:57250 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756099Ab1GGMzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 08:55:53 -0400
In-Reply-To: <20110706210857.GH22090@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 July 2011, Marc MERLIN wrote:
> > The patch I mentioned was merged back in 2006, for 2.6.19. Either that
> > patch was never complete and is missing support for your hardware, or
> > it broke since then. You should probably try an old kernel to see if it's
> > actually a regression.
> 
> Thanks for the details Arnd, I'll see if I can boot 2.6.19 on that laptop
> and report back.

I would perhaps try something less ancient first, 2.6.27-longterm would be
a good candidate. If it was working at some point but broken later, chances
are that it wasn't broken until a few years ago, rather than shortly after
it was merged.

	Arnd
