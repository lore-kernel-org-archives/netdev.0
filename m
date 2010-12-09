From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] xfrm: ESP Traffic Flow Confidentiality padding (v3)
Date: Thu, 9 Dec 2010 20:47:32 +0800
Message-ID: <20101209124732.GA28931@gondor.apana.org.au>
References: <1291819071-17538-1-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291819071-17538-1-git-send-email-martin@strongswan.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 08, 2010 at 03:37:48PM +0100, Martin Willi wrote:
> The following patchset adds Traffic Flow Confidentiality padding. The
> first patch introduces a new Netlink XFRM attribute to configure TFC via
> userspace. Patch two and three implement the padding logic in IPv4 and
> IPv6 ESP. Padding is always done using the RFC4303 format an is clamped
> to the PMTU.
> 
> Changes from v2:
>   - Remove unused flag field in attribute, use a plain u32 as attribute payload
>   - Reject installation of TFC padding on non-tunnel SAs

Looks good to me.  Thanks for the hard work Martin!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
