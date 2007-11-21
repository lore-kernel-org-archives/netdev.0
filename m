From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RE: is it useful testing __LINK_STATE_RX_SCHED in dev_close()?
Date: Wed, 21 Nov 2007 16:54:47 +0800
Message-ID: <20071121085447.GA28411@gondor.apana.org.au>
References: <E1IuhbM-0006tD-00@gondolin.me.apana.org.au> <200711210712.AYG00766@topsec.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: wyb@topsec.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3764 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757170AbXKUIyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 03:54:51 -0500
Content-Disposition: inline
In-Reply-To: <200711210712.AYG00766@topsec.com.cn>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 03:09:52PM +0800, wyb@topsec.com.cn wrote:
> 
> __LINK_STATE_RX_SCHED still exist in kernel 2.6.23.8.

You'll find that it's gone in 2.6.24-rc3.  In any case, the code
was racy but it's too unlikely (and the fix too intrusive) to be
worth fixing in 2.6.23 at this stage.  

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
