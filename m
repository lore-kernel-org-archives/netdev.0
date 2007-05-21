From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] e1000: Don't enable polling in open() (was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Tue, 22 May 2007 07:26:35 +1000
Message-ID: <20070521212635.GA6234@gondor.apana.org.au>
References: <20070521153240.5535.31658.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cebbert@redhat.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4691 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756242AbXEUV0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 17:26:46 -0400
Content-Disposition: inline
In-Reply-To: <20070521153240.5535.31658.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 21, 2007 at 08:32:41AM -0700, Auke Kok wrote:
> Herbert Xy wrote:
> "netif_poll_enable can only be called if you've previously called
> netif_poll_disable.  Otherwise a poll might already be in action
> and you may get a crash like this."
> 
> Removing the call to netif_poll_enable in e1000_open should fix this issue,
> the only other call to netif_poll_enable is in e1000_up() which is only
> reached after a device reset or resume.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Looks good!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
