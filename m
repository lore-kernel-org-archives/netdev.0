From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb
Date: Fri, 9 Apr 2010 16:42:15 +0800
Message-ID: <20100409084215.GA2510@gondor.apana.org.au>
References: <20100408.012617.98660541.davem@davemloft.net> <20100408135715.GA24890@gondor.apana.org.au> <20100408153906.GA26376@gondor.apana.org.au> <20100408.113420.268424579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:48120 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751401Ab0DIImS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:42:18 -0400
Content-Disposition: inline
In-Reply-To: <20100408.113420.268424579.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 11:34:20AM -0700, David Miller wrote:
>
> That still leaves that MC loopback code in ip_dev_loopback_xmit()
> which still sets CHECKSUM_UNNECESSARY unconditionally.
> 
> Should it do like the loopback driver and just leave the ip_summed
> value alone?

Yes I think so.

It will mean an unnecessary verification on the receiving end,
but we could always add CHECKSUM_PARTIAL to the spots that we
care about like your patch did for TCP.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
