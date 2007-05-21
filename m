From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH] ibm_emac: Correctly detect old link speed
Date: Mon, 21 May 2007 15:13:11 +1000
Message-ID: <20070521051311.GB7778@localhost.localdomain>
References: <200705161300.08521.sr@denx.de> <20070516173002.GA22331@gate.ebshome.net> <200705162044.47776.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Surovegin <ebs@ebshome.net>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52214 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864AbXEUFNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 01:13:15 -0400
Content-Disposition: inline
In-Reply-To: <200705162044.47776.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2007 at 08:44:47PM +0200, Stefan Roese wrote:
> On Wednesday 16 May 2007, Eugene Surovegin wrote:
> > On Wed, May 16, 2007 at 01:00:08PM +0200, Stefan Roese wrote:
> > > This patch fixes a bug where the link speed change was not
> > > detected correctly. This occured on a 440SPe (EMAC4) system
> > > where the old link speed was 100Mbps and the new link speed
> > > is 1000Mbps.
> >
> > Good catch, Stefan. Unfortunately, I have to NACK your patch - you
> > broke non EMAC4 builds.
> 
> Yes, you're right of course.
> 
> > Correct fix is just to remove EMAC_MR1_MF_1000GPCS from the first
> > if condition.
> 
> Yep.
> 
> > I'll send correct fix shortly along with other queued patches.
> 
> Thanks.

I've merged essentially the same fix into the device tree aware
"new_emac" driver.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson
