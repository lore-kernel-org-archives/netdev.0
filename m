From: David Miller <davem@davemloft.net>
Subject: Re: ipip: Fix handling of DF packets when pmtudisc is OFF
Date: Fri, 06 Nov 2009 20:36:11 -0800 (PST)
Message-ID: <20091106.203611.35603356.davem@davemloft.net>
References: <20091106203741.GA19736@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760251AbZKGEfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:35:46 -0500
In-Reply-To: <20091106203741.GA19736@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 6 Nov 2009 15:37:41 -0500

> ipip: Fix handling of DF packets when pmtudisc is OFF
...
> This patch fixes the problem by performing PMTU discovery for
> all packets with the inner DF bit set, regardless of the PMTU
> discovery setting on the tunnel itself.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

The fun never ends :-)

Applied to net-2.6, thanks Herbert.
