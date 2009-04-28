From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Tue, 28 Apr 2009 23:20:47 +0800
Message-ID: <20090428152047.GB7549@gondor.apana.org.au>
References: <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090428061225.GA1591@gondor.apana.org.au> <49F71A00.5090701@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52714 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759881AbZD1PU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 11:20:56 -0400
Content-Disposition: inline
In-Reply-To: <49F71A00.5090701@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2009 at 11:00:16AM -0400, Andrew Gallatin wrote:
>
> Its strange, I still consistently see about 1Gb/s better performance
> from LRO than GRO on this weak machine (6.5Gb/s LRO, 5.5Gb/s GRO)
> when binding everything to the same CPU. Mpstat -P 0 shows roughly
> 10% more time spent in "soft" when using GRO vs LRO:

Did you check the utilisation of the all the cores on the sender?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
