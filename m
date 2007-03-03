From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC 1/2] bridge: avoid ptype_all packet handling
Date: Sat, 3 Mar 2007 17:42:22 +1100
Message-ID: <20070303064222.GA1805@gondor.apana.org.au>
References: <20070302.151803.74748558.davem@davemloft.net> <E1HNMxB-0000MP-00@gondolin.me.apana.org.au> <20070302.215905.74747266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4036 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751141AbXCCGmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 01:42:32 -0500
Content-Disposition: inline
In-Reply-To: <20070302.215905.74747266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 02, 2007 at 09:59:05PM -0800, David Miller wrote:
> 
> So it's still a mystery why dhcp is causing bridge devices
> to trigger the network tap paths on Stephen's machine.

If this is the ISC DHCP daemon then perhaps it's because Stephen
didn't specify an interface for it to listen on? By default it'll
enumerate all broadcast interfaces and listen to each one of them.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
