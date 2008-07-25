From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Fri, 25 Jul 2008 13:12:39 -0700 (PDT)
Message-ID: <20080725.131239.163876268.davem@davemloft.net>
References: <BAY103-DAV74E605DFBE7CC22EEA732B2870@phx.gbl>
	<E1KMO85-00052z-00@gondolin.me.apana.org.au>
	<20080725141953.GA19418@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47223
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751577AbYGYUMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 16:12:40 -0400
In-Reply-To: <20080725141953.GA19418@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 25 Jul 2008 22:19:53 +0800

> Actually even more likely, someone has sent you a huge packet
> which triggered this (> 32K if I remember your trace correctly).

I wonder if there are IPSEC implementations out there
that apply IPSEC before doing the MSS/MTU checks and
sizing, for local socket generated frames :-)
