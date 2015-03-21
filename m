From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: provide len to obj_hashfn
Date: Sun, 22 Mar 2015 10:06:18 +1100
Message-ID: <20150321230618.GB31869@gondor.apana.org.au>
References: <1426952290-18962-1-git-send-email-kaber@trash.net>
 <1426952290-18962-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, davem@davemloft.net, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426952290-18962-2-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 21, 2015 at 03:38:09PM +0000, Patrick McHardy wrote:
> nftables sets will be converted to use so called setextensions, moving
> the key to a non-fixed position. To hash it, the obj_hashfn must be used,
> however it so far doesn't receive the length parameter.
> 
> Pass the key length to obj_hashfn() and convert existing users.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

I presume you've got the offset embedded inside the object.  Can
you show us what your actual code looks like? I'm wondering if you
could instead provide rhashtable with a fixed offset key with the
object offset embedded in the key that then lets you go back up to
figure out the object?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
