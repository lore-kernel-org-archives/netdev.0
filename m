From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] e1000: disable polling before registering netdevice
Date: Sat, 2 Jun 2007 08:15:12 +1000
Message-ID: <20070601221512.GA1531@gondor.apana.org.au>
References: <20070601172239.12639.92139.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, doug.chapman@hp.com, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1591 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752035AbXFAWPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 18:15:55 -0400
Content-Disposition: inline
In-Reply-To: <20070601172239.12639.92139.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 01, 2007 at 10:22:39AM -0700, Auke Kok wrote:
> To assure the symmetry of poll enable/disable in up/down, we should
> initialize the netdevice to be poll_disabled at load time. Doing
> this after register_netdevice leaves us open to another race, so
> lets move all the netif_* calls above register_netdevice so the
> stack starts out how we expect it to be.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Doug Chapman <doug.chapman@hp.com>

Looks good!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
