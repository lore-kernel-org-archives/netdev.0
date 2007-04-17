From: Peter Missel <peter.missel@onlinehome.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Tue, 17 Apr 2007 22:36:43 +0200
Message-ID: <200704172236.43280.peter.missel@onlinehome.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <20070416210940.GA13710@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.174]:54563 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbXDQUgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 16:36:54 -0400
In-Reply-To: <20070416210940.GA13710@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Francois!

Thanks for the quick reply.

> > Now after resume, the link is working OK but doesn't come back up to
> > normal gigabit operation. ifdown, unloading and reloading the r8169
> > module, and then ifup again fixes it.
> >
> Can you try 2.6.21-rc7 + (either):
> - http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc7/r8169-20070416
> -
> http://www.fr.zoreil.com/people/francois/misc/20070416-2.6.21-rc7-r8169-tes
>t.patch

Does this patchset work against kernel 2.6.18, or, better yet, is there a 
separate source package that lets me build the current driver on this older 
kernel?

> If it does not work better, please fill an entry for it at
> bugzilla.kernel.org, Cc: it to me and attach the output of a registers dump
> taken from mii-tool before suspend and after a failed resume.

I'll possibly get to trying things out by the end of next week. Until then, 
real life will consume all my spare time.

Thanks so far.

regards,
Peter
