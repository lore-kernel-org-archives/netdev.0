From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] bd4265fe36 bridge: Only flood unreg groups... breaks
	DHCP setup
Date: Wed, 6 Jul 2011 13:45:05 +0800
Message-ID: <20110706054504.GA7786@gondor.apana.org.au>
References: <20110705204200@it-loops.com> <20110705235833.GA5599@gondor.apana.org.au> <20110705.184044.1261486363010308552.davem@davemloft.net> <20110705220636.6afeb81c@nehalam.ftrdhcpuser.net> <20110706050848.GA7564@gondor.apana.org.au> <20110705223551.5e1053af@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mike@it-loops.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43470 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab1GFFpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 01:45:13 -0400
Content-Disposition: inline
In-Reply-To: <20110705223551.5e1053af@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2011 at 10:35:51PM -0700, Stephen Hemminger wrote:
>
> The bisected commit bd4265fe36 is in 3.0-rc4 but the input code
> path still treats multicast and broadcast the same which means
> there are some other possible cases where broadcast doesn't get
> forwarded.

AFAIK it worked properly prior to bd4265fe36 because broadcast
addresses simply get treated as an unregistered multicast group
and ends up being flooded.

So while yes we do do an extra mdb lookup I don't think there is
any visible problem in stable.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
