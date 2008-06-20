From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] fs_enet: restore promiscuous and multicast settings in
 restart()
Date: Fri, 20 Jun 2008 13:50:13 -0400
Message-ID: <20080620135013.36fbafa7.billfink@mindspring.com>
References: <200806181707.17739.laurentp@cse-semaphore.com>
	<20080619230128.def96ee0.billfink@mindspring.com>
	<200806201025.28768.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	pantelis.antoniou@gmail.com, vbordug@ru.mvista.com
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:59289 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752646AbYFTRuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 13:50:16 -0400
In-Reply-To: <200806201025.28768.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jun 2008, Laurent Pinchart wrote:

> On Friday 20 June 2008 05:01, Bill Fink wrote:
> > On Wed, 18 Jun 2008, Laurent Pinchart wrote:
> > 
> > > The restart() function is called when the link state changes and resets
> > > multicast and promiscous settings. This patch restores those settings at 
> the
> > > end of restart().
> > > 
> > > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> > > ---
> > >  drivers/net/fs_enet/mac-fcc.c     |    3 +++
> > >  2 files changed, 4 insertions(+), 1 deletions(-)
> > 
> > Is the whole patch here?  The above says 2 files changed and 5 lines
> > changed, but what's included here is only 1 file and 3 line changes.
> 
> Yes it is. I've hand-removed a completely unrelated change that I had 
> committed to my git tree in the same go (back when I wasn't very familiar 
> with git). Do I need to resubmit ?

I can't answer that.  I just wanted to make sure part of the patch
wasn't accidentally left out.

						-Bill
