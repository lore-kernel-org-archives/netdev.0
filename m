From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] tcp: Repair socket queues
Date: Thu, 03 May 2012 05:31:45 -0400 (EDT)
Message-ID: <20120503.053145.2055460005248115423.davem@davemloft.net>
References: <4F9015ED.7020607@parallels.com>
	<1335957064.22133.428.camel@edumazet-glaptop>
	<4FA248E4.7060501@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465Ab2ECJbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 05:31:49 -0400
In-Reply-To: <4FA248E4.7060501@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 03 May 2012 12:59:16 +0400

> Well, yes, but this ability is given to CAP_SYS_NET_ADMIN users only.
> Do you think it's nonetheless worth accounting this allocation into
> the socket's rmem?

Often such too large lengths can be a bug in the application, so best
to catch it than let it silently succeed.

Also, restricting an operation to "privileged" entities does not mean
we should forego resource utilization checks.
