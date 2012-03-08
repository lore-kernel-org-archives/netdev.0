From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: fix hmac(sha256) truncation length
Date: Thu, 8 Mar 2012 11:37:42 +1100
Message-ID: <20120308003741.GA14995@gondor.apana.org.au>
References: <1331151157-19149-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Paul Wouters <pwouters@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Willi <martin@strongswan.org>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1331151157-19149-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2012 at 03:12:37PM -0500, Jarod Wilson wrote:
> Commit bc74b0c8af17458ecae77f725e507ab5fd100105 added proper hmac sha384
> and sha512 variants with truncation lengths of 192 and 256 respectively,
> per RFC4868:

No, it was done deliberately to maintain backwards compatibility.
Userspace should set the truncbits explicitly from now on.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
