From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv4] fragment locally generated tunnel-mode IPSec6
	packets as needed
Date: Sun, 19 Dec 2010 09:03:53 +0800
Message-ID: <20101219010353.GA1387@gondor.apana.org.au>
References: <1292622162.1700.3.camel@IBM-1B506CFC885> <20101218021606.GA26888@gondor.apana.org.au> <20101218.143423.189688024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56343 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757196Ab0LSBEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 20:04:00 -0500
Content-Disposition: inline
In-Reply-To: <20101218.143423.189688024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 18, 2010 at 02:34:23PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 18 Dec 2010 10:16:06 +0800
> 
> > On Fri, Dec 17, 2010 at 01:42:42PM -0800, David L Stevens wrote:
> >> This patch modifies IPsec6 to fragment IPv6 packets that are
> >> locally generated as needed.
> >> 
> >> This version of the patch only fragments in tunnel mode, so that fragment
> >> headers will not be obscured by ESP in transport mode.
> >> 
> >> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> > 
> > Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> So is the TAHI test regression caused by v3 fixed here in v4?

I think so since that was probably caused by the incorrect
fragmentation of transport-mode packets before encapsulation.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
