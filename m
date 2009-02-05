From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock with icmpv6fuzz
Date: Thu, 05 Feb 2009 15:16:10 -0800 (PST)
Message-ID: <20090205.151610.185227531.davem@davemloft.net>
References: <20090128093507.GA15956@gondor.apana.org.au>
	<20090129.174954.263448549.davem@davemloft.net>
	<20090205130149.GA28152@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43606
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750915AbZBEXQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 18:16:14 -0500
In-Reply-To: <20090205130149.GA28152@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 6 Feb 2009 00:01:49 +1100

> ipv6: Copy cork options in ip6_append_data
> 
> As the options passed to ip6_append_data may be ephemeral, we need
> to duplicate it for corking.  This patch applies the simplest fix
> which is to memdup all the relevant bits.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Great work, applied.
