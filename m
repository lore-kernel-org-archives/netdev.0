From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add rtnl assertion to linkwatch_run_queue
Date: Sat, 29 May 2010 00:01:19 -0700 (PDT)
Message-ID: <20100529.000119.13757121.davem@davemloft.net>
References: <20100527055100.GA21234@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	herbert@gondor.hengli.com.au, kaber@trash.net,
	netdev@vger.kernel.org
To: dkirjanov@hera.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53716
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751811Ab0E2HBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 03:01:09 -0400
In-Reply-To: <20100527055100.GA21234@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Date: Thu, 27 May 2010 05:51:00 +0000

> Add RTNL assertion to linkwatch_run_queue since function 
> must be called with semaphore held
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

This function is exported purely for netdev_wait_allrefs()'s sake
and for no other purpose.

In fact, I'd say this is entirely a private functional interface
specifically built for generic network interface tear-down.

If you are trying to use this function in another context, that's
something you need to discuss with us first before we start peppering
it with various assertions.

I am not applying this patch.
