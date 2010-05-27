From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: Add GSO support on forwarding path
Date: Thu, 27 May 2010 16:14:46 -0700 (PDT)
Message-ID: <20100527.161446.112617306.davem@davemloft.net>
References: <20100526221601.GA3369@gondor.apana.org.au>
	<20100527102429.GA9017@gondor.apana.org.au>
	<20100527115440.GA9952@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56550
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750852Ab0E0XOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 19:14:36 -0400
In-Reply-To: <20100527115440.GA9952@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 27 May 2010 21:54:40 +1000

> On Thu, May 27, 2010 at 08:24:29PM +1000, Herbert Xu wrote:
>> 
>> Actually, this patch is still not quite right for the GSO case.
>> Right now it's only adding the IP header size, not the full header
>> size.
>> 
>> I need to think a bit more about this.
> 
> Let's do it the old way first, so that it at least works for the
> common case.  I'll fix it properly later.
> 
> ipv6: Add GSO support on forwarding path

Ok, applied, thanks Herbert.
