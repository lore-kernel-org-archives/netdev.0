From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Tue, 20 Jan 2009 16:24:51 +1100
Message-ID: <20090120052451.GA19776@gondor.apana.org.au>
References: <20090115211403.3792.24995.stgit@speedy5> <20090119.170308.145804150.davem@davemloft.net> <20090119.180330.255801668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	swise@opengridcomputing.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45701 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750769AbZATFZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 00:25:02 -0500
Content-Disposition: inline
In-Reply-To: <20090119.180330.255801668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2009 at 06:03:30PM -0800, David Miller wrote:
>
> drivers/scsi/cxgb3i/cxgb3i_ddp.h was depending upon the implicit
> inclusion of linux/vmalloc.h coming from the inet_lro.h include
> which is removed by this change.
> 
> In file included from drivers/scsi/cxgb3i/cxgb3i_ddp.c:24:
> drivers/scsi/cxgb3i/cxgb3i_ddp.h: In function 'cxgb3i_alloc_big_mem':
> drivers/scsi/cxgb3i/cxgb3i_ddp.h:148: error: implicit declaration of function 'vmalloc'
> drivers/scsi/cxgb3i/cxgb3i_ddp.h:148: warning: assignment makes pointer from integer without a cast
> drivers/scsi/cxgb3i/cxgb3i_ddp.h: In function 'cxgb3i_free_big_mem':
> drivers/scsi/cxgb3i/cxgb3i_ddp.h:157: error: implicit declaration of function 'vfree'

Thanks Dave!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
