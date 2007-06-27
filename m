From: David Miller <davem@davemloft.net>
Subject: Re: resend [PATCH 2/5 2.6.21] L2TP: Changes to existing ppp and
 socket kernel headers for L2TP
Date: Wed, 27 Jun 2007 01:00:37 -0700 (PDT)
Message-ID: <20070627.010037.34759135.davem@davemloft.net>
References: <200705261747.l4QHlOf8001718@quickie.katalix.com>
	<20070627.001824.15264721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34375
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754066AbXF0IAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 04:00:17 -0400
In-Reply-To: <20070627.001824.15264721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 27 Jun 2007 00:18:24 -0700 (PDT)

> From: James Chapman <jchapman@katalix.com>
> Date: Sat, 26 May 2007 18:47:24 +0100
> 
> > Add struct sockaddr_pppol2tp to carry L2TP-specific address
> > information for the PPPoX (PPPoL2TP) socket. Unfortunately we can't
> > use the union inside struct sockaddr_pppox because the L2TP-specific
> > data is larger than the current size of the union and we must preserve
> > the size of struct sockaddr_pppox for binary compatibility.
> > 
> > Also add a PPPIOCGL2TPSTATS ioctl to allow userspace to obtain
> > L2TP counters and state from the kernel.
> > 
> > Signed-off-by: James Chapman <jchapman@katalix.com>
> 
> This looks OK, patch applied to net-2.6.23, thanks.

Actually, I had to back this out because it depended upon
header files added by subsequent patches and thus broke
the build.
