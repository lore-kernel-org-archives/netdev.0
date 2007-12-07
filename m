From: David Miller <davem@davemloft.net>
Subject: Re: [patch 6/6] ipv6 - route6/fib6 : dont panic a kmem_cache_create
Date: Fri, 07 Dec 2007 00:45:26 -0800 (PST)
Message-ID: <20071207.004526.03229492.davem@davemloft.net>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071206140324.805833763@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60008
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751841AbXLGIp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:45:27 -0500
In-Reply-To: <20071206140324.805833763@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 06 Dec 2007 14:53:35 +0100

> If the kmem_cache_creation fails, the kernel will panic. It is acceptable
> if the system is booting, but if the ipv6 protocol is compiled as a module
> and it is loaded after the system has booted, do we want to panic instead
> of just failing to initialize the protocol ?
> 
> The init function is now returning an error and this one is checked for
> protocol initialization. So the ipv6 protocol will safely fails.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Also applied.
