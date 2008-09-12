From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] retain ABI definitions for obsolete multi-queue packet
 schedulers
Date: Fri, 12 Sep 2008 15:30:33 -0700 (PDT)
Message-ID: <20080912.153033.157394228.davem@davemloft.net>
References: <20080912100011.10c5c6b8@extreme>
	<20080912122548.48945e11@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755567AbYILWak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 18:30:40 -0400
In-Reply-To: <20080912122548.48945e11@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 12 Sep 2008 12:25:48 -0700

> On Fri, 12 Sep 2008 10:00:11 -0700
> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
> > Even though the sch_rr qdisc is now gone in 2.6.27, the kernel
> > definitions for the attributes need to be maintained because applications
> > like iproute need to be compatible with older kernels and use santized
> > kernel headers.
 ...
> This should be applied for 2.6.27 since it is a build regression.

You use a local copy of this header file in iproute2, you don't even
use the kernel header itself.  It's the worst possible example and
excuse for this change.

Nobody references this header directly for these definitions.
The one and only use is using a local copy.

iproute2 is the only thing even remotely referencing this stuff.

So there is no breakage.  The only breakage is if you, Stephen, decide
to copy the kernel header into iproute2 as-is, and that is your
choice.  :-)
