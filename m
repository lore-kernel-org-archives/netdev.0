From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: VLAN vs bridging receive precedence
Date: Fri, 22 Jan 2010 16:11:53 +1300
Message-ID: <20100122031153.GA26565@gondor.apana.org.au>
References: <1264090287.2794.34.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54076 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752640Ab0AVDL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 22:11:57 -0500
Content-Disposition: inline
In-Reply-To: <1264090287.2794.34.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote:
>
> It is not clear which behaviour is 'correct'.  However it appears that
> the XenCenter network management software currently depends on the
> accelerated behaviour.

My question would be why would you have both VLAN and bridging
on the same physical interface in the first place?

These two configurations are well-defined and work as expected:

1) Bridging after VLAN: The bridge only includes the VLAN device,
ethX.Y, not the physical ethX.
2) VLAN after bridging: The VLAN should be linked to the bridge
device, i.e., brX.Y, and not the physical ethX.

So what exactly is the admin trying to achieve here?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
