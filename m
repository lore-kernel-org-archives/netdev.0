From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] tun: fix aio
Date: Mon, 20 Apr 2009 20:09:30 +0800
Message-ID: <20090420120930.GA4941@gondor.apana.org.au>
References: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54381 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754784AbZDTMJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 08:09:37 -0400
Content-Disposition: inline
In-Reply-To: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin <mst@redhat.com> wrote:
>
> Note: I started out just allocating and copying the iovec rather than adding
> yet another skb-iterating routine, but this turned out to add small but
> measurable overhead on data path: tx time per packet jumped from 6500 to 6700 ns
> (let me know if you want to see that version of the patch).

Can you please post the copying version as well so we can compare?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
