From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH -mm 1/2] 3c59x: Fix uninitialized variable bug
Date: Tue, 4 Sep 2007 14:09:47 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709041407210.13651@enigma.security.iitk.ac.in>
References: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in>
 <20070904081602.GB4241@newton.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>,
	Mark Hindley <mark@hindley.org.uk>
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40018 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbXIDI0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 04:26:53 -0400
In-Reply-To: <20070904081602.GB4241@newton.mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steffen,


On Tue, 4 Sep 2007, Steffen Klassert wrote:

> On Tue, Sep 04, 2007 at 03:45:55AM +0530, Satyam Sharma wrote:
> > 
> > drivers/net/3c59x.c: In function 'vortex_up':
> > drivers/net/3c59x.c:1495: warning: 'err' may be used uninitialized in this function
> 
> This came in with the recently applied 3c59x-check-return-of-pci_enable_device patch
> from Mark Hindley. I just compiled it on a PCI only machine so far, therefore I did
> not notice the warning yet.

Hmm, the .config I built with had PCI=y as well. Probably a compiler
version difference -- Jeff also mentioned yesterday that some newer
GCC versions fail to warn about uninitialized variables cases.


> > is a genuine bug. The function returns an uninitialized value of 'err'
> > back to the caller, which expects it to be 0 for success cases. Let's
> > fix this by explicitly initializing 'err' to zero.
> > 
> > Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>


Thanks,

Satyam
