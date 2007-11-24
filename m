From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: wireless vs. alignment requirements
Date: Sat, 24 Nov 2007 21:32:00 +0800
Message-ID: <20071124133200.GA27531@gondor.apana.org.au>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au> <1195893216.4149.186.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsd@gentoo.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3813 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751676AbXKXNcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 08:32:25 -0500
Content-Disposition: inline
In-Reply-To: <1195893216.4149.186.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 24, 2007 at 09:33:36AM +0100, Johannes Berg wrote:
>
> We still require four-byte alignment, no?

Not at all.  If NET_IP_ALIGN is zero then it won't be four-byte
aligned (since the Ethernet header is 14 bytes long).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
