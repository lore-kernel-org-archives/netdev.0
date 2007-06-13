From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 0/15] spidernet driver bug fixes
Date: Wed, 13 Jun 2007 11:14:14 -0500
Message-ID: <20070613161414.GO4397@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <466F2581.2080808@garzik.org> <20070612233237.GN4397@austin.ibm.com> <466F3482.4050305@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:60861 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758200AbXFMQOR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 12:14:17 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5DGEG2o024202
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 12:14:16 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5DGEG0h447488
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 12:14:16 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5DGEFpM027290
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 12:14:16 -0400
Content-Disposition: inline
In-Reply-To: <466F3482.4050305@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 08:04:18PM -0400, Jeff Garzik wrote:
> >
> >>Should I just drop all spidernet patches and start over?
> >
> >No. Apply the series I just sent you, dropping the one called
> >"patch 6/15", the one from Florin Malita, as it appears you'd
> >previously picked this up.  The rest of the patches should apply
> >cleanly; I just cheked. I just did a "git pull" of 
> >git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6
> >and checked. The result of patching is exactly as it should be.
> >
> 
> As I just stated, many of the patches in the "current" patch series have 
> 
> Linas Vepstas (11):
>       s2io: add PCI error recovery support
>       s2io: add PCI error recovery support
>       spidernet: beautify error messages
>       spidernet: move a block of code around
>       spidernet: zero out a pointer.
>       spidernet: null out skb pointer after its been used.
>       spidernet: Don't terminate the RX ring
>       spidernet: enhance the dump routine
>       spidernet: reset the card when an rxramfull is seen
>       spidernet: service TX later.
>       spidernet: increase the NAPI weight
> 
> These are clearly duplicating some of the patches in your patchseries, 
> which means you are woefully out of sync with upstream.
> already been applied to netdev-2.6.git#upstream:

My apologies; I'm trying.  Seems that I've tripped over a git "feature".

"git branch" shows that I'm on "upstream".  So I performed a "git pull" 
(without any additional arguments) assuming that it would sync to your
"upstream" branch.  And so my email was based on this.

Some googling seems to show that "git pull" has a bug/feature of
ignoring the branch that one is working in, and pulling "master"
no matter what.  I have no clue why; this seems broken to me.

So ... let me try again ... 
git pull git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6 upstream
...
Automatic merge failed; fix up by hand

So not only did "git pull" not fetch the correct branch, but it also
wrecked the repository.  Glug. I have no clue how to recover from this.

I suggest dropping the above series of spidernet patches, and reapplying 
the series of 15 I'd sent in. 

--linas

