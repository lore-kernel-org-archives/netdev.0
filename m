From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 01 May 2008 03:51:08 -0700 (PDT)
Message-ID: <20080501.035108.190262472.davem@davemloft.net>
References: <E1JrVtK-0001pb-00@gondolin.me.apana.org.au>
	<20080501.033414.132094744.davem@davemloft.net>
	<20080501103854.GA7285@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47797
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754116AbYEAKvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:51:10 -0400
In-Reply-To: <20080501103854.GA7285@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 1 May 2008 18:38:54 +0800

> I still don't understand why we can't forward LRO packets.  It
> should be no different to forwarding GSO packets if it's properly
> constructed.

Hmmm, you should be right.

On the output path, if the device can't GSO, we'll software
un-GSO it.

Perhaps the issue is that it's expensive to do that, and thus
it could harm routing performance in such cases.
