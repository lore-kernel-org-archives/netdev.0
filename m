From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/24] [IPSEC]: Add async resume support on output
Date: Tue, 13 Nov 2007 21:44:01 -0800 (PST)
Message-ID: <20071113.214401.145445436.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1Ipla9-0001IX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbXKNFoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:44:02 -0500
In-Reply-To: <E1Ipla9-0001IX-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:37 +0800

> [IPSEC]: Add async resume support on output
> 
> This patch adds support for async resumptions on output.  To do so, the
> transform would return -EINPROGRESS and subsequently invoke the function
> xfrm_output_resume to resume processing.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This stuff is so nice now :-)

Applied to net-2.6.25
