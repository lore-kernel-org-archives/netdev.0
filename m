From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 8 Apr 2010 20:30:25 +0800
Message-ID: <20100408123025.GA23762@gondor.apana.org.au>
References: <20100408.035049.177640912.davem@davemloft.net> <20100408114738.GA23329@gondor.apana.org.au> <20100408.051144.183699401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:45811 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758597Ab0DHMa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:30:28 -0400
Content-Disposition: inline
In-Reply-To: <20100408.051144.183699401.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 05:11:44AM -0700, David Miller wrote:
>
> We have the socket pointer etc. already in dev_queue_xmit_nit(), so we
> can easily do it.

It doesn't look trivial to me since AF_PACKET fiddles with packet
headers before running the filter...

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
