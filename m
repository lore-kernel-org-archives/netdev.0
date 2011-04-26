From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 3/4] xfrm: Check for the new replay
 implementation if an esn state is inserted
Date: Tue, 26 Apr 2011 12:47:58 -0700 (PDT)
Message-ID: <20110426.124758.112584358.davem@davemloft.net>
References: <20110426053923.GF5495@secunet.com>
	<20110426054121.GH5495@secunet.com>
	<20110426054304.GD18896@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48380
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756558Ab1DZTsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 15:48:31 -0400
In-Reply-To: <20110426054304.GD18896@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 26 Apr 2011 15:43:04 +1000

> On Tue, Apr 26, 2011 at 07:41:21AM +0200, Steffen Klassert wrote:
>> IPsec extended sequence numbers can be used only with the new
>> anti-replay window implementation. So check if the new implementation
>> is used if an esn state is inserted and return an error if it is not.
>> 
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
