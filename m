From: Mark Hindley <mark@hindley.org.uk>
Subject: Re: [PATCH -mm 1/2] 3c59x: Fix uninitialized variable bug
Date: Tue, 4 Sep 2007 09:53:31 +0100
Message-ID: <20070904085331.GH5944@hindley.org.uk>
References: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in> <20070904081602.GB4241@newton.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 83-216-141-215.markhi700.adsl.metronet.co.uk ([83.216.141.215]:4366
	"EHLO mx.hindley.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbXIDIyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 04:54:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 04, 2007 at 02:09:47PM +0530, Satyam Sharma wrote:
> Hi Steffen,
> 
> 
> On Tue, 4 Sep 2007, Steffen Klassert wrote:
> 
> > On Tue, Sep 04, 2007 at 03:45:55AM +0530, Satyam Sharma wrote:
> > > 
> > > drivers/net/3c59x.c: In function 'vortex_up':
> > > drivers/net/3c59x.c:1495: warning: 'err' may be used uninitialized in this function
> > 
> > This came in with the recently applied 3c59x-check-return-of-pci_enable_device patch
> > from Mark Hindley. I just compiled it on a PCI only machine so far, therefore I did
> > not notice the warning yet.
> 
> Hmm, the .config I built with had PCI=y as well. Probably a compiler
> version difference -- Jeff also mentioned yesterday that some newer
> GCC versions fail to warn about uninitialized variables cases.
> 

Sorry, this is my bad. I have just checked: there is no warning with gcc
4.2 or 4.1, but 3.3 emits the warning. 

> 
> > > is a genuine bug. The function returns an uninitialized value of 'err'
> > > back to the caller, which expects it to be 0 for success cases. Let's
> > > fix this by explicitly initializing 'err' to zero.
> > > 
> > > Signed-off-by: Satyam Sharma <satyam@infradead.org>
> > Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

Acked-by: Mark Hindley <mark@hindley.org.uk>
