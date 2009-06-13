From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
 configuration.
Date: Sat, 13 Jun 2009 00:07:29 -0700 (PDT)
Message-ID: <20090613.000729.118500646.davem@davemloft.net>
References: <ba4215e10906120519o35358caducfdd253c9f8d8bd2@mail.gmail.com>
	<20090612.170128.213931980.davem@davemloft.net>
	<4A334E7A.5020805@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nico@cam.org, netdev@vger.kernel.org
To: mfuzzey@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762765AbZFMHH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 03:07:27 -0400
In-Reply-To: <4A334E7A.5020805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Fuzzey <mfuzzey@gmail.com>
Date: Sat, 13 Jun 2009 09:00:10 +0200

> But please reply to the rest of that message, in particular explain why,
> having publicly stated you would accept an implementation of Nicolas'
> idea, you are now back pedaling.

I misunderstood the problem, thanks for asking me to clarify
this.

I thought the issue was the "in the environment where his devices
would be used" he wanted to force a certain link speed and duplex
setting.  In that case, forcing the link via ethtool is appropriate
because it's an attribute of where the device is connected.

But the situation is different, the physical hardware has a limitation
and know of this belongs, or should be described, in the driver
somehow.
