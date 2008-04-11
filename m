From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 2/2] [POWERPC] UCC nodes cleanup
Date: Fri, 11 Apr 2008 21:11:09 +0400
Message-ID: <20080411171109.GA16119@polina.dev.rtsoft.ru>
References: <20080311171045.GB4684@localhost.localdomain> <82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org> <20080411160654.GA25506@polina.dev.rtsoft.ru> <47FF9665.7020403@freescale.com> <20080411170657.GA15270@polina.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Kumar Gala <galak@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:7029 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759521AbYDKRLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 13:11:10 -0400
Content-Disposition: inline
In-Reply-To: <20080411170657.GA15270@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 09:06:57PM +0400, Anton Vorontsov wrote:
> On Fri, Apr 11, 2008 at 11:48:37AM -0500, Timur Tabi wrote:
> > Anton Vorontsov wrote:
> > > On Fri, Apr 11, 2008 at 09:13:36AM -0500, Kumar Gala wrote:
> > >> On Mar 11, 2008, at 12:10 PM, Anton Vorontsov wrote:
> > >>> - get rid of `model = "UCC"' in the ucc nodes
> > >>>  It isn't used anywhere, so remove it. If we'll ever need something
> > >>>  like this, we'll use compatible property instead.
> > >>> - replace cell-index and device-id properties by fsl,ucc.
> > >>>
> > >>> Drivers are modified for backward compatibility's sake.
> > >> I'd prefer we use cell-index and not introduce "fsl,ucc".  I'm ok with  
> > >> dropping device-id and model (its implied in the compatiable).
> > > 
> > > Ok. Here it is. netdev and linux-serial Cc'ed.
> > 
> > Do we want the first UCC to have a cell-index of 1?  Maybe we should fix this
> > off-by-one error once and for all, and number all UCCs from 0?
> 
> Isn't documentation numbers UCC from 1? Then I believe we should stick
> with it for device tree, since off by one is Linux implementation details.

Or maybe I'm thinking here in terms of "fsl,ucc"... and cell-index is
indeed should be -1... don't know. Please decide. ;-)

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
