From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: Send netlink notification when DAD fails
Date: Sat, 13 Mar 2010 12:23:40 -0800 (PST)
Message-ID: <20100313.122340.214239484.davem@davemloft.net>
References: <20100313111117.GA25903@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53222
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932971Ab0CMUXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 15:23:19 -0500
In-Reply-To: <20100313111117.GA25903@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 13 Mar 2010 19:11:17 +0800

> ipv6: Send netlink notification when DAD fails
> 
> If we are managing IPv6 addresses using DHCP, it would be nice
> for user-space to be notified if an address configured through
> DHCP fails DAD.  Otherwise user-space would have to poll to see
> whether DAD succeeds.
> 
> This patch uses the existing notification mechanism and simply
> hooks it into the DAD failure code path.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
