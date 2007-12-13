From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix reversed ICMP6 policy check
Date: Wed, 12 Dec 2007 18:54:46 -0800 (PST)
Message-ID: <20071212.185446.112976256.davem@davemloft.net>
References: <20071213015856.GA32668@gondor.apana.org.au>
	<20071212.184830.25856041.davem@davemloft.net>
	<20071213025155.GA784@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbXLMCyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 21:54:47 -0500
In-Reply-To: <20071213025155.GA784@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Dec 2007 10:51:56 +0800

> You're too quick :) Before you ask for an incremental patch, here's
> a preemptive strike :)

Hehe :)

> [IPSEC]: Do not let packets pass when ICMP flag is off
> 
> This fixes a logical error in ICMP policy checks which lets
> packets through if the state ICMP flag is off.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
