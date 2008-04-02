From: David Miller <davem@davemloft.net>
Subject: Re: [PING^2] [PATCH] srandom32 fixes for networking
Date: Wed, 02 Apr 2008 01:20:22 -0700 (PDT)
Message-ID: <20080402.012022.106064938.davem@davemloft.net>
References: <20080402075011.GL29105@one.firstfloor.org>
	<20080402.010324.121433616.davem@davemloft.net>
	<20080402082103.GN29105@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47332
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752037AbYDBIUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 04:20:21 -0400
In-Reply-To: <20080402082103.GN29105@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 2 Apr 2008 10:21:03 +0200

> On Wed, Apr 02, 2008 at 01:03:24AM -0700, David Miller wrote:
> > From: Andi Kleen <andi@firstfloor.org>
> > Date: Wed, 2 Apr 2008 09:50:11 +0200
> > 
> > > Can you send me your config please? I don't see any build problem
> > > here with the patch on top of -rc7-git something on either i386 nor x86-64.
> > 
> > I found it with "git grep srandom32", I guess I'm quite old school in
> > that I actually check the tree when interfaces are being changed.
> 
> Ah I see the problem now.  The patch requires 
> 
> ftp://firstfloor.org/pub/ak/misc/patches/pageattr-own-random
> 
> applied first to remove this reference. Sorry should 
> have made that more clear.  The original post had both
> patches, but in the reposts the reference to the dependency
> got dropped somehow, sorry.

You have to decide how to submit this without introducing
the build failure then.

I would suggest getting your first change in, and when that
happens, resubmit this one.
