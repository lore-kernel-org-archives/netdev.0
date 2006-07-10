From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] inetpeer: Get rid of volatile from peer_total
Date: Sun, 09 Jul 2006 18:18:18 -0700 (PDT)
Message-ID: <20060709.181818.42440047.davem@davemloft.net>
References: <20060709230711.GA19901@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44727
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964958AbWGJBRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 21:17:37 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060709230711.GA19901@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 10 Jul 2006 09:07:11 +1000

> [IPV4] inetpeer: Get rid of volatile from peer_total
> 
> The variable peer_total is protected by a lock.  The volatile marker
> makes no sense.  This shaves off 20 bytes on i386.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
