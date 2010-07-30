From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] act_nat: the checksum of ICMP doesn't have pseudo
	header
Date: Fri, 30 Jul 2010 17:09:22 +0800
Message-ID: <20100730090922.GA7807@gondor.apana.org.au>
References: <1280448258-1893-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:55281 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780Ab0G3JJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 05:09:32 -0400
Content-Disposition: inline
In-Reply-To: <1280448258-1893-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 30, 2010 at 08:04:18AM +0800, Changli Gao wrote:
> after updating the value of the ICMP payload, inet_proto_csum_replace4() should
> be called with zero pseudohdr.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

No, the code is correct as is.  We need to update the checksum
even if the checksum is partial, which is what the 1 is for.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
