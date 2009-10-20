From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 20 Oct 2009 09:54:15 +0900
Message-ID: <20091020005415.GA3937@gondor.apana.org.au>
References: <200910161824.n9GIOuoX010135@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amathur@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53906 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755609AbZJTAyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 20:54:12 -0400
Content-Disposition: inline
In-Reply-To: <200910161824.n9GIOuoX010135@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rasesh Mody <rmody@brocade.com> wrote:
.
> +static int bnad_lro_get_skb_header(struct sk_buff *skb, void **iphdr,
> +    void **tcphdr, u64 *hdr_flags, void *priv)

Please stop using LRO in new code.  The GRO replacement should
be used instead.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
