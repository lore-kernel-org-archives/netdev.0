From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] skbuff: clear tx zero-copy flag
Date: Mon, 25 Jul 2011 08:42:00 +0800
Message-ID: <20110725004200.GA25794@gondor.apana.org.au>
References: <1310195566.25391.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49409 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685Ab1GYAmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2011 20:42:13 -0400
Content-Disposition: inline
In-Reply-To: <1310195566.25391.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shirley Ma <mashirle@us.ibm.com> wrote:
> 
> This patch clears tx zero-copy flag as needed.
> 
> Sign-off-by: Shirley Ma <xma@us.ibm.com>

I think we also need to copy and clear this flag on the splice
read path as that takes a direct page reference.

I hope there isn't any other path that does this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
