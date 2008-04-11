From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 2/2] [POWERPC] UCC nodes cleanup
Date: Fri, 11 Apr 2008 21:31:00 +0400
Message-ID: <20080411173100.GA20439@polina.dev.rtsoft.ru>
References: <20080311171045.GB4684@localhost.localdomain> <82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org> <20080411160654.GA25506@polina.dev.rtsoft.ru> <47FF9665.7020403@freescale.com> <20080411170657.GA15270@polina.dev.rtsoft.ru> <20080411171109.GA16119@polina.dev.rtsoft.ru> <47FF9BFE.5000201@freescale.com> <20080411172106.GA17786@polina.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:7071 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760012AbYDKRbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 13:31:02 -0400
Content-Disposition: inline
In-Reply-To: <20080411172106.GA17786@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 09:21:06PM +0400, Anton Vorontsov wrote:
> On Fri, Apr 11, 2008 at 12:12:30PM -0500, Timur Tabi wrote:
> > Anton Vorontsov wrote:
> > 
> > > Or maybe I'm thinking here in terms of "fsl,ucc"... and cell-index is
> > > indeed should be -1... don't know. Please decide. ;-)
> > 
> > Well, that's what I was thinking.  cell-index is zero-based, so UCC1 should have
> > cell-index = <0>.
> > 
> > Of course, this means all the code needs to change, since I think device-id is
> > one-based.
> 
> Yup. You raised a really good question, because we're _introducing_
> cell-index for UCC nodes, and if we'll choice wrong numbering scheme
> now, then there will be no way back w/o breaking backward compatibility.

Hm... thinking about it more, we're introducing implementation for the
cell-index, but device tree was "infected" already.

So, too late. :-D

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
