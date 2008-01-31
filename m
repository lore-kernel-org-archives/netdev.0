From: David Miller <davem@davemloft.net>
Subject: Re: ipcomp regression in 2.6.24
Date: Wed, 30 Jan 2008 21:48:48 -0800 (PST)
Message-ID: <20080130.214848.193710194.davem@davemloft.net>
References: <E1JK3QD-0006hM-00@gondolin.me.apana.org.au>
	<BAY103-DAV204C57458B3E41DE1AA365B2360@phx.gbl>
	<20080131053221.GA4739@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pupilla@hotmail.com, Daniel.Beschorner@facton.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750783AbYAaFs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 00:48:28 -0500
In-Reply-To: <20080131053221.GA4739@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 31 Jan 2008 16:32:21 +1100

> [IPCOMP]: Fix reception of incompressible packets
> 
> I made a silly typo by entering IPPROTO_IP (== 0) instead of
> IPPROTO_IPIP (== 4).  This broke the reception of incompressible
> packets.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
