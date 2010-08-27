From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v3] gro: __napi_gro_receive() optimizations
Date: Thu, 26 Aug 2010 21:38:16 -0700 (PDT)
Message-ID: <20100826.213816.112615295.davem@davemloft.net>
References: <20100825.135726.189708768.davem@davemloft.net>
	<1282770911.2681.205.camel@edumazet-laptop>
	<1282883713.2501.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35639
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752002Ab0H0EiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 00:38:00 -0400
In-Reply-To: <1282883713.2501.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Aug 2010 06:35:13 +0200

> +	fold |= *(unsigned long *)(a + 6) ^ *(unsigned long *)(b + 6);

Shouldn't these be "+ 8" instead of "+ 6"?
