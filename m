From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix reversed ICMP6 policy check
Date: Wed, 12 Dec 2007 18:48:30 -0800 (PST)
Message-ID: <20071212.184830.25856041.davem@davemloft.net>
References: <20071212.162613.186792052.davem@davemloft.net>
	<20071212173951.4f1eb99a.akpm@linux-foundation.org>
	<20071213015856.GA32668@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58755
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751666AbXLMCsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 21:48:31 -0500
In-Reply-To: <20071213015856.GA32668@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Dec 2007 09:58:56 +0800

> [IPSEC]: Fix reversed ICMP6 policy check
> 
> The policy check I added for ICMP on IPv6 is reversed.  This
> patch fixes that.
> 
> It also adds an skb->sp check so that unprotected packets that
> fail the policy check do not crash the machine.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
