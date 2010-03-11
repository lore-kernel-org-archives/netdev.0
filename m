From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 15:15:29 -0800 (PST)
Message-ID: <20100311.151529.16498686.davem@davemloft.net>
References: <20100311145059.1a020e1c@nehalam>
	<20100311.145412.118613343.davem@davemloft.net>
	<20100311151050.31f8ad5d@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41794
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753585Ab0CKXPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:15:09 -0500
In-Reply-To: <20100311151050.31f8ad5d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 11 Mar 2010 15:10:50 -0800

> But if non utilities will already adapt to new/old kernel, so
> just don't put out 64 bit values if the platform is 32 bit.
> When/if 32 bit platforms support it, great add the extra stats.

How about we just make userland ready for it and:

1) Emitting it now will get it tested even on 32-bit

2) They'll be ready when the drivers can keep track of
   64-bit stats too.

Stephen I've heard your side of the story, I just don't
agree with it :-)
