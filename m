From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] [IPV4/IPV6]: Fail registration if inet device
 construction fails
Date: Mon, 30 Jul 2007 17:05:01 -0700 (PDT)
Message-ID: <20070730.170501.63996168.davem@davemloft.net>
References: <20070726090725.GA510@gondor.apana.org.au>
	<E1IDzLm-0000AP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53659
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764682AbXGaAFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:05:02 -0400
In-Reply-To: <E1IDzLm-0000AP-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Jul 2007 17:09:38 +0800

> [IPV4/IPV6]: Fail registration if inet device construction fails
> 
> Now that netdev notifications can fail, we can use this to signal
> errors during registration for IPv4/IPv6.  In particular, if we
> fail to allocate memory for the inet device, we can fail the netdev
> registration.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
