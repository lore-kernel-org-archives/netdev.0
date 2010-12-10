From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Fix xfrm_state_migrate leak
Date: Thu, 09 Dec 2010 20:36:01 -0800 (PST)
Message-ID: <20101209.203601.112597520.davem@davemloft.net>
References: <20101207092856.GL4639@secunet.com>
	<20101207093157.GA4845@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, thomas.egerer@secunet.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54618
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755718Ab0LJEfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 23:35:33 -0500
In-Reply-To: <20101207093157.GA4845@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 7 Dec 2010 17:31:57 +0800

> On Tue, Dec 07, 2010 at 10:28:56AM +0100, Steffen Klassert wrote:
>> From: Thomas Egerer <thomas.egerer@secunet.com>
>> 
>> xfrm_state_migrate calls kfree instead of xfrm_state_put to free
>> a failed state. According to git commit 553f9118 this can cause
>> memory leaks.
>> 
>> Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Good catch.  Thanks!

Applied, thanks.
