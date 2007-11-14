From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/24] [IPSEC]: Use dst->header_len when resizing on
 output
Date: Tue, 13 Nov 2007 21:33:12 -0800 (PST)
Message-ID: <20071113.213312.121424501.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZq-0001G4-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751476AbXKNFdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:33:13 -0500
In-Reply-To: <E1IplZq-0001G4-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:18 +0800

> [IPSEC]: Use dst->header_len when resizing on output
> 
> Currently we use x->props.header_len when resizing on output.  However,
> if we're resizing at all we might as well go the whole hog and do it
> for the whole dst.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
