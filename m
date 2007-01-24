From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 23 Jan 2007 22:08:08 -0800 (PST)
Message-ID: <20070123.220808.85689314.davem@davemloft.net>
References: <20070119110641.GA3135@ff.dom.local>
	<20070119211027.GA16626@gondor.apana.org.au>
	<20070122065214.GA1634@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mjt@tls.msk.ru,
	netdev@vger.kernel.org, kaber@trash.net
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54321
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030244AbXAXGIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:08:09 -0500
In-Reply-To: <20070122065214.GA1634@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Mon, 22 Jan 2007 07:52:14 +0100

> [PATCH][NET] tcp_output: rare bad TCP checksum with 2.6.19
> 
> The patch "Replace CHECKSUM_HW by CHECKSUM_PARTIAL/CHECKSUM_COMPLETE"
> changed to unconditional copying of ip_summed field from collapsed
> skb. This patch reverts this change.
> 
> The majority of substantial work including heavy testing
> and diagnosing by: Michael Tokarev <mjt@tls.msk.ru>
> Possible reasons pointed by: Herbert Xu and Patrick McHardy.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot everyone.

I'll take care of submitting this to 2.6.19-stable.

Thanks again.
