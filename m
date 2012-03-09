From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: fix hmac(sha256) truncation length
Date: Sat, 10 Mar 2012 00:45:42 +1100
Message-ID: <20120309134541.GA28309@gondor.apana.org.au>
References: <1331151157-19149-1-git-send-email-jarod@redhat.com> <20120308003741.GA14995@gondor.apana.org.au> <4F5A0876.3060408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Paul Wouters <pwouters@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Willi <martin@strongswan.org>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F5A0876.3060408@redhat.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2012 at 08:41:10AM -0500, Jarod Wilson wrote:
>
> Okay, I suspected that might be the case. No plans to ever invert that,  
> so that userspace has to explicitly set the shorter truncbits for  
> backwards compat?

That's up to the userspace implementation.  If its configuration
allows explicit trunc bits then just use whatever the user says.
Otherwise it'll have to make a policy decision.  For example, a
big warning when upgrading and changing the default to the correct
value.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
