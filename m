From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] xfrm: Traffic Flow Confidentiality for IPv4 ESP
Date: Wed, 8 Dec 2010 16:49:54 +0800
Message-ID: <20101208084954.GA15252@gondor.apana.org.au>
References: <1291717744-30111-1-git-send-email-martin@strongswan.org> <1291717744-30111-3-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60451 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab0LHIt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 03:49:57 -0500
Content-Disposition: inline
In-Reply-To: <1291717744-30111-3-git-send-email-martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 07, 2010 at 11:29:03AM +0100, Martin Willi wrote:
> Add TFC padding to all packets smaller than the boundary configured
> on the xfrm state. If the boundary is larger than the PMTU, limit
> padding to the PMTU.

Thanks for the update Martin.

However, I still think it's more complicated than it needs be.
In particular, why would we need a boundary at all? Setting it to
anything other than the PMTU would seem to defeat the purpose of
TFC for packets between the boundary and the PMTU.

If we can get rid of tfc.pad, we can simplify the user-interface
change to just adding an xfrm_state flag.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
