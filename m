From: David Miller <davem@davemloft.net>
Subject: Re: [1/7] [IPSEC]: Move linux/crypto.h inclusion out of net/xfrm.h
Date: Sat, 05 Aug 2006 01:48:54 -0700 (PDT)
Message-ID: <20060805.014854.65629240.davem@davemloft.net>
References: <20060804133157.GA12787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14784
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422769AbWHEIsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 04:48:46 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060804133157.GA12787@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 4 Aug 2006 23:31:57 +1000

> [IPSEC]: Move linux/crypto.h inclusion out of net/xfrm.h
> 
> The header file linux/crypto.h is only needed by a few files so including
> it in net/xfrm.h (which is included by half of the networking stack) is a
> waste.  This patch moves it out of net/xfrm.h and into the specific header
> files that actually need it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
