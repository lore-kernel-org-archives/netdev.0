From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: DST_NOHASH flag and IPsec transformers routing tables - need some clarification
Date: Thu, 29 Nov 2007 10:59:22 +0800
Message-ID: <20071129025922.GA20723@gondor.apana.org.au>
References: <d0383f90711260515p6155bd7bt196016fb4d8d4cdf@mail.gmail.com> <E1IwphB-0000Ff-00@gondolin.me.apana.org.au> <d0383f90711280555s6fa62802w92bcd026f78bb5ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ian Brown <ianbrn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2316 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758392AbXK2C7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 21:59:30 -0500
Content-Disposition: inline
In-Reply-To: <d0383f90711280555s6fa62802w92bcd026f78bb5ac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2007 at 03:55:19PM +0200, Ian Brown wrote:
>
> no need to cache this entry ? because as I understand it , next
> sk_buff with the same dest IP will have to get this same
> dst_entry (the head of the list). So why not cache this head of the
> list of dst_entries ?

It's not in the routing cache because IPsec lookups are done through the
flow cache.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
