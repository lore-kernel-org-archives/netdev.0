From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.32: padlock_sha1 and hmac broken?
Date: Sat, 30 Jan 2010 13:27:21 +1100
Message-ID: <20100130022721.GA8324@gondor.apana.org.au>
References: <201001300044.15769.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46039 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752639Ab0A3C1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 21:27:23 -0500
Content-Disposition: inline
In-Reply-To: <201001300044.15769.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 30, 2010 at 12:44:15AM +0100, Wolfgang Walter wrote:
> Hello,
> 
> I upgraded some machines with VIA processors from (vanilla) 2.6.31 to 
> 2.6.32.7.
> 
> If I build the kernel 2.6.32.7 with CONFIG_CRYPTO_DEV_PADLOCK_SHA=y and 
> padlock supports sha, hmac(sha1) is missing and IPSEC with hmac(sha1) no 
> longer is possible.

Can you please attach the dmesg output so we can see if there
were any error messages?

Please also try "modprobe tcrypt mode=101".

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
