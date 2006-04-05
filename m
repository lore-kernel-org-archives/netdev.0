From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [IPSEC] Avoid null pointer dereference in xfrm4_rcv_encap
Date: Thu, 6 Apr 2006 03:10:22 +1000
Message-ID: <20060405171022.GA14590@gondor.apana.org.au>
References: <1144249178.10340.5.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751298AbWDERLB@vger.kernel.org>
To: Dave Kleikamp <shaggy@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <1144249178.10340.5.camel@kleikamp.austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 05, 2006 at 09:59:38AM -0500, Dave Kleikamp wrote:
> I'm getting a panic that I've traced back to this changeset:
> http://www.kernel.org/git/gitweb.cgi?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e695633e21ffb6a443a8c2f8b3f095c7f1a48eb0
> 
> xfrm4_rcv_encap dereferences x->encap without testing it for null.

The fix for this bug has just been merged.  Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
