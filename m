From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][BRIDGE] Lost call to br_fdb_fini() in br_init() error path
Date: Thu, 29 Nov 2007 23:45:22 +1100
Message-ID: <20071129124522.GD30420@gondor.apana.org.au>
References: <474C2C2E.7050001@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3189 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755414AbXK2Mpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 07:45:31 -0500
Content-Disposition: inline
In-Reply-To: <474C2C2E.7050001@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 05:39:42PM +0300, Pavel Emelyanov wrote:
> In case the br_netfilter_init() (or any subsequent call) 
> fails, the br_fdb_fini() must be called to free the allocated
> in br_fdb_init() br_fdb_cache kmem cache.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Patch applied to net-2.6.  Thanks Pavel!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
