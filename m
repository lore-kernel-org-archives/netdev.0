From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC v2 PATCH 2/9] xfrm: Add basic infrastructure to support
	IPsec extended sequence numbers
Date: Sun, 13 Mar 2011 14:44:57 +0800
Message-ID: <20110313064457.GB10849@gondor.apana.org.au>
References: <20110308100407.GB31402@secunet.com> <20110308100543.GD31402@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Alex Badea <abadea@ixiacom.com>,
	Andreas Gruenbacher <agruen@suse.de>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:50148 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab1CMGpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 01:45:07 -0500
Content-Disposition: inline
In-Reply-To: <20110308100543.GD31402@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2011 at 11:05:43AM +0100, Steffen Klassert wrote:
> This patch adds the struct xfrm_replay_state_esn which will be
> used to support IPsec extended sequence numbers and anti replay windows
> bigger than 32 packets. Also we add a function that returns the actual
> size of the xfrm_replay_state_esn, a xfrm netlink atribute and a xfrm state
> flag for the use of extended sequence numbers.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

All the remaining eight patches look good to me.

Dave, how would you like to handle this patch-set? As Steffen's
first crypto patch is completely self-contained, perhaps you could
just include it along with the rest of the series in your tree?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
