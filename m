From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macsec: key identifier is 128 bits, not 64
Date: Mon, 09 May 2016 00:09:24 -0400 (EDT)
Message-ID: <20160509.000924.1876830470382020347.davem@davemloft.net>
References: <a4f37c780ee1a5c368662bb389274995b2b51dbc.1462644509.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbcEIEJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 00:09:31 -0400
In-Reply-To: <a4f37c780ee1a5c368662bb389274995b2b51dbc.1462644509.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Sat,  7 May 2016 20:19:29 +0200

> The MACsec standard mentions a key identifier for each key, but
> doesn't specify anything about it, so I arbitrarily chose 64 bits.
> 
> IEEE 802.1X-2010 specifies MKA (MACsec Key Agreement), and defines the
> key identifier to be 128 bits (96 bits "member identifier" + 32 bits
> "key number").
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
