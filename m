From: David Miller <davem@davemloft.net>
Subject: Re: TOE, etc.
Date: Tue, 27 Jun 2006 21:43:23 -0700 (PDT)
Message-ID: <20060627.214323.92582051.davem@davemloft.net>
References: <20060628033708.GA4922@gondor.apana.org.au>
	<44A20311.5050301@pobox.com>
	<20060628042959.GA5561@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, swise@opengridcomputing.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10939
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423094AbWF1EnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 00:43:25 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060628042959.GA5561@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 28 Jun 2006 14:29:59 +1000

> On Wed, Jun 28, 2006 at 12:18:25AM -0400, Jeff Garzik wrote:
> > 
> > A PCI device that presents itself as a SCSI controller, but under the 
> > hood is really iSCSI-over-TCP smells like TOE.  Running a virtualized 
> > Linux guest on top of a proprietary stack [which provides networking 
> > services to guests] also smells like TOE.  :)
> 
> Agreed.  However, when they start adding hooks to the ARP table, the
> routing table, and PMTU management, it begs the question what more is
> there to add for TOE (well, user-space driven TOE at least)?

Socket state, and that is one thing I don't see them doing yet.

> Put it another way, I think the dividing line between TOE and iSCSI or
> virtualisation is exactly the interface between them and the Linux kernel.
> If the interface is an existing one such as SCSI or standard IP then it's
> OK.  However, when it starts poking in the guts of the Linux stack I'd say
> that it has crossed the line.

Yeah, it's starting to smell really bad.

But we have to realize they've already been given %95 of the
interfaces they need to speak IP using our routes and our neighbour
entries.

Right?
