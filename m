From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Fix IGMP3 report parsing
Date: Wed, 07 Apr 2010 21:21:02 -0700 (PDT)
Message-ID: <20100407.212102.46860906.davem@davemloft.net>
References: <20100408012634.GC18649@gondor.apana.org.au>
	<20100407.205248.113724360.davem@davemloft.net>
	<20100408040709.GA19944@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, banyeer@yahoo.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38659
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751454Ab0DHEVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:21:00 -0400
In-Reply-To: <20100408040709.GA19944@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 8 Apr 2010 12:07:09 +0800

> On Wed, Apr 07, 2010 at 08:52:48PM -0700, David Miller wrote:
>> 
>> If pskb_may_pull() actually does anything non-trivial,
>> skb->data will change and you'll be referring to freed
>> up memory.
>> 
>> That's probably why you had the grec assignment where
>> you originally had it in the first place :-)
> 
> Heh, you're clearly more awake than I was :)

:-)

> bridge: Fix IGMP3 report parsing
> 
> The IGMP3 report parsing is looking at the wrong address for
> group records.  This patch fixes it.
> 
> Reported-by: Banyeer <banyeer@yahoo.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
