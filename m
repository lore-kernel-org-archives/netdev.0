From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] [IPSEC]: Use IPv6 calling convention as the
 convention for x->mode->output
Date: Wed, 10 Oct 2007 15:44:54 -0700 (PDT)
Message-ID: <20071010.154454.117701486.davem@davemloft.net>
References: <20071010143915.GA7650@gondor.apana.org.au>
	<E1IfcjN-00024M-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756371AbXJJWov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:44:51 -0400
In-Reply-To: <E1IfcjN-00024M-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Oct 2007 22:40:13 +0800

> [IPSEC]: Use IPv6 calling convention as the convention for x->mode->output
> 
> The IPv6 calling convention for x->mode->output is more general and could
> help an eventual protocol-generic x->type->output implementation.  This
> patch adopts it for IPv4 as well and modifies the IPv4 type output functions
> accordingly.
> 
> It also rewrites the IPv6 mac/transport header calculation to be based off
> the network header where practical.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
