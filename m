From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] via-ircc: Pass PCI device pointer to
 dma_{alloc,free}_coherent()
Date: Wed, 30 Mar 2011 00:13:09 -0700 (PDT)
Message-ID: <20110330.001309.258110623.davem@davemloft.net>
References: <1301368243.26693.751.camel@localhost>
	<1301368372.26693.753.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrewb@bgc.com.au, samuel@sortiz.org,
	619450@bugs.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42438
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754405Ab1C3HNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 03:13:47 -0400
In-Reply-To: <1301368372.26693.753.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 29 Mar 2011 04:12:52 +0100

> via-ircc has been passing a NULL pointer to DMA allocation functions,
> which is completely invalid and results in a BUG on PowerPC.  Now
> that we always have the device pointer available, pass it in.
> 
> Reference: http://bugs.debian.org/619450
> Reported-by: Andrew Buckeridge <andrewb@bgc.com.au>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Tested-by: Andrew Buckeridge <andrewb@bgc.com.au> [against 2.6.32]

Applied.
