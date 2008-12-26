From: David Miller <davem@davemloft.net>
Subject: Re: gro: Fix potential use after free
Date: Fri, 26 Dec 2008 14:57:59 -0800 (PST)
Message-ID: <20081226.145759.148181271.davem@davemloft.net>
References: <20081226224401.GA22329@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751899AbYLZW54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 17:57:56 -0500
In-Reply-To: <20081226224401.GA22329@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 27 Dec 2008 09:44:01 +1100

> gro: Fix potential use after free
> 
> The initial skb may have been freed after napi_gro_complete in
> napi_gro_receive if it was merged into an existing packet.  Thus
> we cannot check same_flow (which indicates whether it was merged)
> after calling napi_gro_complete.
> 
> This patch fixes this by saving the same_flow status before the
> call to napi_gro_complete.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
