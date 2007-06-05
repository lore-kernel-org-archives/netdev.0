From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [IPV4]: Only panic if inetdev_init fails for
 loopback
Date: Mon, 04 Jun 2007 23:34:17 -0700 (PDT)
Message-ID: <20070604.233417.130239068.davem@davemloft.net>
References: <20070605062929.GA12024@gondor.apana.org.au>
	<E1HvSZJ-0003A3-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36090
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757649AbXFEGeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 02:34:03 -0400
In-Reply-To: <E1HvSZJ-0003A3-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 05 Jun 2007 16:31:01 +1000

> [IPV4]: Only panic if inetdev_init fails for loopback
> 
> When I made the inetdev_init call work on all devices I incorrectly
> left in the panic call as well.  It is obviously undesirable to
> panic on an allocation failure for a normal network device.  This
> patch moves the panic call under the loopback if clause.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
