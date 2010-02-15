From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] macvtap: Add GSO/csum offload support
Date: Mon, 15 Feb 2010 08:21:31 +0800
Message-ID: <20100215002131.GC15437@gondor.apana.org.au>
References: <1266013667.6105.18.camel@w-sridhar.beaverton.ibm.com> <201002131834.00612.arnd@arndb.de> <4B7711C9.2090800@us.ibm.com> <201002142013.08745.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43061 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751365Ab0BOAVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 19:21:44 -0500
Content-Disposition: inline
In-Reply-To: <201002142013.08745.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 14, 2010 at 08:13:08PM +0100, Arnd Bergmann wrote:
>
> Ah, good point. Will that also work for the checksumming? Also, should the
> host really be doing segmentation and checksumming for the guest if the
> hardware can't do it? So even if everything works correctly, we might
> want to let the guest do the work in order to get accounting of the CPU
> cycles right.

Yes the amount you save by ensuring we postpone the processing until
as last as possible is tremendous.

As for accounting, it depends on how we structure the vhost backend.
If it could stay in the process context of the qemu process then all
should be fine.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
