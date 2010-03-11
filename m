From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 13:30:26 -0800 (PST)
Message-ID: <20100311.133026.147122543.davem@davemloft.net>
References: <20100311121239.14944fd5@nehalam>
	<20100311.122639.258785986.davem@davemloft.net>
	<alpine.LSU.2.01.1003112205360.24500@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45962
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751385Ab0CKVaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 16:30:07 -0500
In-Reply-To: <alpine.LSU.2.01.1003112205360.24500@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Thu, 11 Mar 2010 22:07:07 +0100 (CET)

> On a side note, is it perhaps possible to use jiffies-like magic to
> also have 64-bit counters on 32-bit, or is that still too expensive?

I think there might still be atomicity issues.

We've been telling people to poll periodically in userspace to avoid
these problems, but that has limitations as network speeds increase.
