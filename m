From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] tcp6: Add GRO support
Date: Thu, 08 Jan 2009 10:41:43 -0800 (PST)
Message-ID: <20090108.104143.97576942.davem@davemloft.net>
References: <20090107031404.GA16827@gondor.apana.org.au>
	<20090107031536.GA18655@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757194AbZAHSlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 13:41:42 -0500
In-Reply-To: <20090107031536.GA18655@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 7 Jan 2009 14:15:36 +1100

> tcp6: Add GRO support
> 
> This patch adds GRO support for TCP over IPv6.  The code is exactly
> the same as the IPv4 version except for the pseudo-header checksum
> computation.
> 
> Note that I've removed the unused tcphdr argument from tcp_v6_check
> rather than invent a bogus value for GRO.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
