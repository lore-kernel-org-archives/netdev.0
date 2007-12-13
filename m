From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix zero return value in xfrm_lookup on error
Date: Thu, 13 Dec 2007 09:31:30 -0800 (PST)
Message-ID: <20071213.093130.98177469.davem@davemloft.net>
References: <20071213164448.GA7310@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36229
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758412AbXLMRbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:31:31 -0500
In-Reply-To: <20071213164448.GA7310@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 14 Dec 2007 00:44:48 +0800

> [IPSEC]: Fix zero return value in xfrm_lookup on error
> 
> Further testing shows that my ICMP relookup patch can cause xfrm_lookup
> to return zero on error which isn't very nice since it leads to the caller
> dying on null pointer dereference.  The bug is due to not setting err
> to ENOENT just before we leave xfrm_lookup in case of no policy.
> 
> This patch moves the err setting to where it should be.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
