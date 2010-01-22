From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: VLAN vs bridging receive precedence
Date: Sat, 23 Jan 2010 09:13:31 +1300
Message-ID: <20100122201331.GA2974@gondor.apana.org.au>
References: <20100122031153.GA26565@gondor.apana.org.au> <1264180303.2784.19.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50823 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753622Ab0AVUNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 15:13:34 -0500
Content-Disposition: inline
In-Reply-To: <1264180303.2784.19.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 22, 2010 at 05:11:42PM +0000, Ben Hutchings wrote:
.
> The administrator might just be trying to bridge a VLAN to a guest.
> 
> XenCenter attaches a bridge interface ('Network') to each NIC.  The
> administrator can define additional Networks which are associated with
> VLANs on specific NICs; for each of these it attaches a VLAN interface
> to the physical interface and a bridge interface to the VLAN interface.

But that should work perfectly.  The problem here is that the
bridge is being attached to the physical interface, no?

> Ideally people wouldn't mix tagged and untagged traffic, and then
> XenCenter could refuse to bridge both a physical interface and a VLAN
> attached to it.  In practice, people do mix them, and I think we need to
> work out what the proper semantics are.

Mixing should work as well, as long as you don't attach both
bridging and VLAN to the physical interface.

Cheeers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
