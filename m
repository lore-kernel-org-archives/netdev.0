From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Wed, 28 Feb 2007 23:30:34 -0800 (PST)
Message-ID: <20070228.233034.74746721.davem@davemloft.net>
References: <45E67B04.2060702@linux-foundation.org>
	<20070228.232224.74746939.davem@davemloft.net>
	<45E6802C.2090708@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55130
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933040AbXCAHag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 02:30:36 -0500
In-Reply-To: <45E6802C.2090708@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 28 Feb 2007 23:26:36 -0800

> sounds like a socket option would help, the data is already there. Then 
> the normal
> UDP receive path would work.

That would be perfect for new applications.

But we have to support all the old ones, so we're stuck
providing correctly functioning AF_PACKET handling on
all devices, sorry.

And in fact that effectively makes the new socket option
pointless, since it doesn't buy us anything since we have
to support the old stuff fully anyways.
