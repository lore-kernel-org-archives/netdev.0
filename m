From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix CAN info leak/minor heap overflow
Date: Tue, 09 Nov 2010 09:05:23 -0800 (PST)
Message-ID: <20101109.090523.189685701.davem@davemloft.net>
References: <1288722503.2504.14.camel@dan>
	<ygfiq0bsjry.fsf@janus.isnogud.escape.de>
	<4CD8FDB5.6060905@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, security@kernel.org,
	torvalds@linux-foundation.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43621
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754268Ab0KIRE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 12:04:59 -0500
In-Reply-To: <4CD8FDB5.6060905@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Tue, 09 Nov 2010 08:52:21 +0100

> Once this patch is applied (and the procfs layout is changed anyway), i'd also
> like to send a patch from my backlog that would extend the procfs output for
> can-bcm with an additional drop counter.

I find this kind of discussion extremely disappointing.

All of this stuff you CAN guys do with procfs files and version
strings is completely wrong and bogus.

Once you create a procfs file layout, you're basically stuck and you
can at best only reasonably add new fields at the end, you can't
really change existing fields.

And sysfs would have been a lot more appropriate, you could use
attributes for each value you want to export and then just add new
sysfs attributes when you want to export new values which has very
clear semantics and backwards compatability implications.
