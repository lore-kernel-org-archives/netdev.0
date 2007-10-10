From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] [IPSEC]: Move IP length/checksum setting out of
 transforms
Date: Wed, 10 Oct 2007 15:46:00 -0700 (PDT)
Message-ID: <20071010.154600.82098434.davem@davemloft.net>
References: <20071010143915.GA7650@gondor.apana.org.au>
	<E1IfcjP-00024c-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756497AbXJJWp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:45:58 -0400
In-Reply-To: <E1IfcjP-00024c-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Oct 2007 22:40:15 +0800

> [IPSEC]: Move IP length/checksum setting out of transforms
> 
> This patch moves the setting of the IP length and checksum fields out of
> the transforms and into the xfrmX_output functions.  This would help future
> efforts in merging the transforms themselves.
> 
> It also adds an optimisation to ipcomp due to the fact that the transport
> offset is guaranteed to be zero.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

APplied.
