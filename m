From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Mon, 16 Apr 2007 12:17:46 -0700 (PDT)
Message-ID: <20070416.121746.39159168.davem@davemloft.net>
References: <4623BB7B.3010705@psc.edu>
	<7e63f56c0704161151p405c4597x5fbac6021b635d84@mail.gmail.com>
	<4623CA4B.3000503@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: coroberti@gmail.com, netdev@vger.kernel.org,
	greearb@candelatech.com
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49172
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753317AbXDPTRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 15:17:44 -0400
In-Reply-To: <4623CA4B.3000503@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Mon, 16 Apr 2007 15:11:07 -0400

> I don't know if this qualifies as an unconditional bug.  The commit 
> above was actually a bugfix so that the limits were not higher than 
> total memory on some systems, but had the side effect that it made them 
> even smaller on your particular configuration.  Also, having initial 
> sysctl values that are conservatively small probably doesn't qualify as 
> a bug (for patching stable trees).  You might ask the -stable 
> maintainers if they have a different opinion.
> 
> For most people, 2.6.19 and 2.6.20 work fine.  For those who really care 
> about the tcp_mem values (are using a substantial fraction of physical 
> memory for TCP connections), the best bet is to set the tcp_mem sysctl 
> values in the startup scripts, or use the new initialization function in 
> 2.6.21.

What's most important is determining if that tcp_mem[] patch actually
fixes his problem, so it is his responsibility to see whether this
is the case.

If it does fix the problem, I'm happy to submit the backport to -stable.

But until such tests are made, it's just speculation whether the patch
fixes the problem or not, and therefore there is zero justification to
submit it to -stable.
