From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] AF_RXRPC: Add blkcipher accessors for using kernel
 data directly
Date: Mon, 02 Apr 2007 20:22:15 -0700 (PDT)
Message-ID: <20070402.202215.21596343.davem@davemloft.net>
References: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com>
	<20070402224458.31568.45303.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37972
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751450AbXDCDWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 23:22:16 -0400
In-Reply-To: <20070402224458.31568.45303.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 02 Apr 2007 23:44:58 +0100

> Add blkcipher accessors for using kernel data directly without the
> use of scatter lists.
>
> Also add a CRYPTO_ALG_DMA algorithm capability flag to permit or deny the use
> of DMA and hardware accelerators.  A hardware accelerator may not be used to
> access any arbitrary piece of kernel memory lest it not be in a DMA'able
> region.  Only software algorithms may do that.

I'll let Herbert, the crypto layer maintainer, decide on this one.
I can put it into net-2.6.22 in order to make the RXRPC integration
easier if Herbert is OK with this.

Please be sure to CC: Herbert and/or the crypto lists on any future
crypto layer patches David, thanks.
