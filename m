From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH] e1000: Don't enable polling in open() (was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Tue, 22 May 2007 11:01:37 +1000
Message-ID: <20070522010137.GC8130@gondor.apana.org.au>
References: <20070521215134.14885.84952.stgit@localhost.localdomain> <46522E6F.9060600@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Auke Kok <auke-jan.h.kok@intel.com>, stable@vger.kernel.org,
	greg@suse.de, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, davej@redhat.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1860 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756034AbXEVBBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 21:01:46 -0400
Content-Disposition: inline
In-Reply-To: <46522E6F.9060600@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 21, 2007 at 07:42:39PM -0400, Jeff Garzik wrote:
>
> applied, though as a poster (DaveJ?) noted, I'm not sure it completely 
> fixes the bug

It should fix the problem completely in 2.6.22.  For 2.6.21, we need
a different fix because e1000_open is directly calling e1000_up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
