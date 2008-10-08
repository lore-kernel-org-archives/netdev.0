From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 10/14] ipv6: ICMP6MSGIN_INC_STATS is not used
Date: Wed, 08 Oct 2008 11:23:36 -0700 (PDT)
Message-ID: <20081008.112336.78710325.davem@davemloft.net>
References: <1223466722-8169-10-git-send-email-den@openvz.org>
	<OFA8E1BB63.D89C2A10-ON882574DC.00607E02-882574DC.0060CF64@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, benjamin.thery@bull.net, dlezcano@fr.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	xemul@openvz.org, yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56432
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754757AbYJHSYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 14:24:00 -0400
In-Reply-To: <OFA8E1BB63.D89C2A10-ON882574DC.00607E02-882574DC.0060CF64@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 8 Oct 2008 10:37:25 -0700

> This is there to parallel the definitions for other stats
> macros. I don't think it should be removed, since it's
> part of the standard interface for incrementing counters.
> If someone has a need to increment it without, say, _BH,
> I wouldn't want them to have to come up with it from
> scratch again...
> 
> It's cost is the two lines of code it takes, but you could
> consider it "documentation" for any future users that
> want that variant.

I disagree.

It's more work to change interfaces globally like these namespace
guys frequently have to, if we leave unused interfaces around.

The changelog history clearly contains the old macro so it can
be resurrected properly, and folks such as you or myself can
point this out if someone adds an improper reimplementation.
