From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 05/15] dec netdev: relocate DIGITAL based drivers to
 legacy
Date: Fri, 29 Oct 2010 05:54:56 +0100 (BST)
Message-ID: <alpine.LFD.2.00.1010290545270.25426@eddie.linux-mips.org>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>        <1288315159-1350-6-git-send-email-paul.gortmaker@windriver.com>        <alpine.LFD.2.00.1010290516110.25426@eddie.linux-mips.org>
 <20101028.212939.189691515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:33845 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab0J2Ey5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 00:54:57 -0400
Received: from localhost.localdomain ([127.0.0.1]:55357 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1491016Ab0J2Ey4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 06:54:56 +0200
In-Reply-To: <20101028.212939.189691515.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Oct 2010, David Miller wrote:

> >  NAK for the TURBOchannel bits (defxx.[ch] and declance.c) unless you give 
> > a plausible justification.  You won't get these drivers offered unless you 
> > have the bus in your system anyway, and if you do than you don't want to 
> > have them hidden somewhere in the corner.  If you see anything wrong with 
> > these drivers, then please do let me know.
> > 
> >  Also defxx.c is PCI too (apart from being EISA and TC).
> 
> PCI things can be legacy too.
> 
> This is not about a specific bus technology, it's simply for
> "really old stuff" so we can declutter the top-level of drivers/net

 Hmm, what's the difference between placing these drivers here or there 
and what's so particular about them that they cause clutter?  I mean a 
mere high number of items does not cause a mess by itself -- the lack of 
order might.

 Also -- if this change goes ahead -- when I add new TURBOchannel drivers, 
should they go straight to legacy/?  It sounds odd to me to have a thing 
obsolete straight from the beginning.

  Maciej
