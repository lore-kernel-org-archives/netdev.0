From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Delete redundant sk_family assignment
Date: Sun, 01 Feb 2009 22:24:57 -0800 (PST)
Message-ID: <20090201.222457.138957378.davem@davemloft.net>
References: <20090202061918.GA23990@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54810
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751437AbZBBGZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 01:25:01 -0500
In-Reply-To: <20090202061918.GA23990@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 2 Feb 2009 17:19:18 +1100

> ipv4: Delete redundant sk_family assignment
> 
> sk_alloc now sets sk_family so this is redundant.  In fact it caught
> my eye because sock_init_data already uses sk_family so this is too
> late anyway.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
