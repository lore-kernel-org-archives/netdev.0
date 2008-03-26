From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH resend]: Fix output for BEET ipsec
Date: Wed, 26 Mar 2008 21:31:52 +0800
Message-ID: <20080326133152.GA3022@gondor.apana.org.au>
References: <200803261115.26157.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Komu Miika <Miika.Komu@hiit.fi>
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38967 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755775AbYCZNby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 09:31:54 -0400
Content-Disposition: inline
In-Reply-To: <200803261115.26157.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 11:15:26AM +0200, Joakim Koskela wrote:
> Hi,
> 
> Any comments on this? Would be great to get beet working soon!
> 
> br, j
> 
> == original post:
> 
> This patch fixes the ipsec BEET (Bound End-to-End Tunnel) mode
> interfamily handling of the net-2.6 (25-rc3) kernel, as specified by
> the ietf draft found at:
> 
> http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-08.txt
> 
> It is sent as a RFC as it doesn't fit that neatly into the newly
> cleaned-up xfrm model - I suspect that there could be a better way to
> solve this.
> 
> Signed-off-by: Joakim Koskela <jookos@gmail.com>

Thanks for the patch!

In light of the patch I just posted I believe we can drop everything
but the props_header_len adjustments.  Please let me know if it still
doesn't work with my earlier patch.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
