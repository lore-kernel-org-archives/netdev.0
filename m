From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-2.6 be2net: fix to get RX IDs 0 and 1
Date: Thu, 16 Sep 2010 21:50:56 -0700 (PDT)
Message-ID: <20100916.215056.133407514.davem@davemloft.net>
References: <20100916113842.GA3937@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59645
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750818Ab0IQEui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 00:50:38 -0400
In-Reply-To: <20100916113842.GA3937@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 16 Sep 2010 17:09:02 +0530

> Change made to allocate RX IDs 0 and 1 for the two ports.
> To get RX Q IDs 0 and 1 enable RSS Capability for that interface.
> RX IDs 0 and 1 have 32 bit drop counters which will take a long time
> to wrap around thereby presenting a consistent stats display.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

I don't understand this commit message at all.

The patch looks like it's simply respecting capability flags
stored in the chip, and thus will now enable RSS on more
interfaces than it did before.

And that has absolutely nothing to do with allocating specific
RX IDs or anything like that.

It also, therefore, has nothing to do with fixing any kind of
serious regression in this driver.  Therefore this patch is
absolutely not appropriate for net-2.6

Please give a more accurate and understandable commit message
for this patch, and target it for net-next-2.6 unless you can
show that this fixes a very serious bug in 2.6.36
