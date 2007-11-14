From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPSEC]: Add async resume support on input
Date: Tue, 13 Nov 2007 22:33:56 -0800 (PST)
Message-ID: <20071113.223356.216207937.davem@davemloft.net>
References: <20071113.214609.04000914.davem@davemloft.net>
	<20071114062758.GA11173@gondor.apana.org.au>
	<20071114062834.GB11173@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758813AbXKNGd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:33:57 -0500
In-Reply-To: <20071114062834.GB11173@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Nov 2007 14:28:34 +0800

> [IPSEC]: Add async resume support on input
> 
> This patch adds support for async resumptions on input.  To do so, the
> transform would return -EINPROGRESS and subsequently invoke the function
> xfrm_input_resume to resume processing.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied to net-2.6.25, thanks.

I'll work on integrating Patrick's NF_INET_* patch next.
