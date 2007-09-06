From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH -mm 1/2] 3c59x: Fix uninitialized variable bug
Date: Thu, 6 Sep 2007 15:25:55 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709061515090.3781@enigma.security.iitk.ac.in>
References: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in>
 <20070904081602.GB4241@newton.mathematik.tu-chemnitz.de>
 <20070904085331.GH5944@hindley.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
To: Mark Hindley <mark@hindley.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:50640 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbXIFJm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 05:42:57 -0400
In-Reply-To: <20070904085331.GH5944@hindley.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 4 Sep 2007, Mark Hindley wrote:

> On Tue, Sep 04, 2007 at 02:09:47PM +0530, Satyam Sharma wrote:
> > Hi Steffen,
> > 
> > 
> > On Tue, 4 Sep 2007, Steffen Klassert wrote:
> > 
> > > On Tue, Sep 04, 2007 at 03:45:55AM +0530, Satyam Sharma wrote:
> > > > 
> > > > drivers/net/3c59x.c: In function 'vortex_up':
> > > > drivers/net/3c59x.c:1495: warning: 'err' may be used uninitialized in this function
> > > 
> > > This came in with the recently applied 3c59x-check-return-of-pci_enable_device patch
> > > from Mark Hindley. I just compiled it on a PCI only machine so far, therefore I did
> > > not notice the warning yet.
> > 
> > Hmm, the .config I built with had PCI=y as well. Probably a compiler
> > version difference -- Jeff also mentioned yesterday that some newer
> > GCC versions fail to warn about uninitialized variables cases.
> > 
> 
> Sorry, this is my bad. I have just checked: there is no warning with gcc
> 4.2 or 4.1, but 3.3 emits the warning. 

This is a GCC bug (regression, actually, as you've found out) -- no two
ways about it. Although different from the kind Jeff mentioned couple days
back -- that was about wising GCC up to false positives and /not/ emitting
warnings. But here a genuine problem was not complained about, so this is
more serious. Do you plan to open up a bug at gcc.gnu.org/bugzilla/ ?


Satyam
