From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TOE, etc. (was Re: [PATCH Round 3 0/2][RFC] Network Event Notifier Mechanism)
Date: Wed, 28 Jun 2006 14:29:59 +1000
Message-ID: <20060628042959.GA5561@gondor.apana.org.au>
References: <20060627205050.30723.25753.stgit@stevo-desktop> <E1FvQBu-00018u-00@gondolin.me.apana.org.au> <20060628030400.GA4474@gondor.apana.org.au> <44A1F669.8070606@pobox.com> <20060628033708.GA4922@gondor.apana.org.au> <44A20311.5050301@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1035 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030324AbWF1EaR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 00:30:17 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <44A20311.5050301@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 28, 2006 at 12:18:25AM -0400, Jeff Garzik wrote:
> 
> A PCI device that presents itself as a SCSI controller, but under the 
> hood is really iSCSI-over-TCP smells like TOE.  Running a virtualized 
> Linux guest on top of a proprietary stack [which provides networking 
> services to guests] also smells like TOE.  :)

Agreed.  However, when they start adding hooks to the ARP table, the
routing table, and PMTU management, it begs the question what more is
there to add for TOE (well, user-space driven TOE at least)?
 
> Unfortunately I don't have more details, so you just get a generalized 
> rant :)

OK, the patch under discussion here adds hooks to all the stuff in the
previous paragraph for the purpose of RDMA over TCP (well I must say
that the exact RDMA application/hardware has never been clearly given
but this is what I can gather from the previous posts).

Put it another way, I think the dividing line between TOE and iSCSI or
virtualisation is exactly the interface between them and the Linux kernel.
If the interface is an existing one such as SCSI or standard IP then it's
OK.  However, when it starts poking in the guts of the Linux stack I'd say
that it has crossed the line.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
