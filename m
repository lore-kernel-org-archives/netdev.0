From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 07 Jan 2009 23:44:52 +1100
Message-ID: <E1LKXmG-0006nY-14@gondolin.me.apana.org.au>
References: <20090106155715.GA28783@1wt.eu>
Cc: jarkao2@gmail.com, jens.axboe@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: w@1wt.eu (Willy Tarreau)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46575 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753807AbZAGMpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:45:05 -0500
In-Reply-To: <20090106155715.GA28783@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau <w@1wt.eu> wrote:
> 
> root@wtap:~# ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: off
> tx-checksumming: off
> scatter-gather: off
> tcp segmentation offload: off

Can you please upgrade your ethtool so that it knows about GSO?
Once you've done that please retest with everything including
GSO turned off.

Alternatively edit out the bit that enables GSO by default in
net/core/dev.c.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
