From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/12] Trying to merge xfrm input path before I got side-tracked...
Date: Tue, 16 Oct 2007 22:18:44 +0800
Message-ID: <20071016141843.GA11956@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2452 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932306AbXJPOSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:18:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

I was well on my way to merging the xfrm input path before I got
side-tracked by inter-family transforms :)

Anyway, here's a dump of what I've got.  The one note-worthy bit
is the patch to reinject transport mode packets through netif_rx
rather than calling netfilter directly.

Everything else is pretty mundane (modulo any bugs of course).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
