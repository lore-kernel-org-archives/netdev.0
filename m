From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PING^2] [PATCH] srandom32 fixes for networking
Date: Wed, 2 Apr 2008 10:21:03 +0200
Message-ID: <20080402082103.GN29105@one.firstfloor.org>
References: <20080401113408.GA625@basil.nowhere.org> <20080402.001824.161259886.davem@davemloft.net> <20080402075011.GL29105@one.firstfloor.org> <20080402.010324.121433616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:42005 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbYDBIRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 04:17:13 -0400
Content-Disposition: inline
In-Reply-To: <20080402.010324.121433616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2008 at 01:03:24AM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Wed, 2 Apr 2008 09:50:11 +0200
> 
> > Can you send me your config please? I don't see any build problem
> > here with the patch on top of -rc7-git something on either i386 nor x86-64.
> 
> I found it with "git grep srandom32", I guess I'm quite old school in
> that I actually check the tree when interfaces are being changed.

Ah I see the problem now.  The patch requires 

ftp://firstfloor.org/pub/ak/misc/patches/pageattr-own-random

applied first to remove this reference. Sorry should 
have made that more clear.  The original post had both
patches, but in the reposts the reference to the dependency
got dropped somehow, sorry.

-Andi
