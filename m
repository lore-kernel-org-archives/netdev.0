From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 2/2] [POWERPC] UCC nodes cleanup
Date: Fri, 11 Apr 2008 21:21:06 +0400
Message-ID: <20080411172106.GA17786@polina.dev.rtsoft.ru>
References: <20080311171045.GB4684@localhost.localdomain> <82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org> <20080411160654.GA25506@polina.dev.rtsoft.ru> <47FF9665.7020403@freescale.com> <20080411170657.GA15270@polina.dev.rtsoft.ru> <20080411171109.GA16119@polina.dev.rtsoft.ru> <47FF9BFE.5000201@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Kumar Gala <galak@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <linux-serial-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47FF9BFE.5000201@freescale.com>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 11, 2008 at 12:12:30PM -0500, Timur Tabi wrote:
> Anton Vorontsov wrote:
> 
> > Or maybe I'm thinking here in terms of "fsl,ucc"... and cell-index is
> > indeed should be -1... don't know. Please decide. ;-)
> 
> Well, that's what I was thinking.  cell-index is zero-based, so UCC1 should have
> cell-index = <0>.
> 
> Of course, this means all the code needs to change, since I think device-id is
> one-based.

Yup. You raised a really good question, because we're _introducing_
cell-index for UCC nodes, and if we'll choice wrong numbering scheme
now, then there will be no way back w/o breaking backward compatibility.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
