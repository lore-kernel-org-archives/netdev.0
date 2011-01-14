From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/10] GRETH: added greth_compat_mode module parameter
Date: Thu, 13 Jan 2011 22:14:54 -0800 (PST)
Message-ID: <20110113.221454.149673942.davem@davemloft.net>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
	<1294907135-24884-4-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: daniel@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46333
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750859Ab1ANGOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 01:14:21 -0500
In-Reply-To: <1294907135-24884-4-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Hellstrom <daniel@gaisler.com>
Date: Thu, 13 Jan 2011 09:25:29 +0100

> The greth_compat_mode option can be used to set a GRETH GBit capable MAC
> in operate as if the GRETH 10/100 device was found. The GRETH GBit supports
> TCP/UDP checksum offloading, unaligned frame buffers, scatter gather etc.
> Enabling this mode allows the developer to test the GRETH 10/100 device
> without all features mentioned above on a GBit MAC capable of the above.
> 
> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>

No special device specific module parameters please.

What if every single driver author added something like this and they
all named it something different or made it behave in slightly differing
ways?

What kind of user experience would that result in?

It would result in a sucky one, which is why we avoid adding all kinds
of hacky driver specific module options.

Find a generic way to provide this functionality.
