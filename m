From: David Miller <davem@davemloft.net>
Subject: Re: poor network loopback performance and scalability
Date: Mon, 21 Apr 2008 03:22:00 -0700 (PDT)
Message-ID: <20080421.032200.209759978.davem@davemloft.net>
References: <20080421081103.GA31328@elte.hu>
	<20080421.011623.67335122.davem@davemloft.net>
	<20080421101908.GC9295@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32859
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753041AbYDUKV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 06:21:58 -0400
In-Reply-To: <20080421101908.GC9295@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 21 Apr 2008 18:19:08 +0800

> I belive the current value is a legacy from the days when we didn't
> support skb page frags so everything had to be physically contiguous.

It's legacy from when my top-of-the-line UltraSPARC-I 130Mhz cpus
got the best loopback results using that value :-)
