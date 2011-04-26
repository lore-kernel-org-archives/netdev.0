From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/4] xfrm: Fix replay window size calculation
 on initialization
Date: Tue, 26 Apr 2011 12:47:44 -0700 (PDT)
Message-ID: <20110426.124744.104072806.davem@davemloft.net>
References: <20110426053923.GF5495@secunet.com>
	<20110426054107.GB18896@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48370
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755474Ab1DZTsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 15:48:18 -0400
In-Reply-To: <20110426054107.GB18896@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 26 Apr 2011 15:41:07 +1000

> On Tue, Apr 26, 2011 at 07:39:24AM +0200, Steffen Klassert wrote:
>> On replay initialization, we compute the size of the replay
>> buffer to see if the replay window fits into the buffer.
>> This computation lacks a mutliplication by 8 because we need
>> the size in bit, not in byte. So we might return an error
>> even though the replay window would fit into the buffer.
>> This patch fixes this issue.
>> 
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
