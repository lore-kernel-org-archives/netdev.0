From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/24] [NET]: Remove unnecessary inclusion of dst.h
Date: Tue, 13 Nov 2007 21:34:43 -0800 (PST)
Message-ID: <20071113.213443.66181390.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZt-0001GS-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37442
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751759AbXKNFeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:34:44 -0500
In-Reply-To: <E1IplZt-0001GS-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:21 +0800

> [NET]: Remove unnecessary inclusion of dst.h
> 
> The file net/netevent.h only refers to struct dst_entry * so it doesn't
> need to include dst.h.  I've replaced it with a forward declaration.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
