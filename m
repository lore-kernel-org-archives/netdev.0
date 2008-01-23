From: David Miller <davem@davemloft.net>
Subject: Re: [INET]: Fix truesize setting in ip_append_data
Date: Tue, 22 Jan 2008 21:47:19 -0800 (PST)
Message-ID: <20080122.214719.168781298.davem@davemloft.net>
References: <20080123033942.GA698@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41430
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752798AbYAWFrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 00:47:11 -0500
In-Reply-To: <20080123033942.GA698@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 23 Jan 2008 14:39:42 +1100

> [INET]: Fix truesize setting in ip_append_data
> 
> As it is ip_append_data only counts page fragments to the skb that
> allocated it.  As such it means that the first skb gets hit with a
> 4K charge even though it might have only used a fraction of it while
> all subsequent skb's that use the same page gets away with no charge
> at all.
> 
> This bug was exposed by the UDP accounting patch.
> 
> This patch also fixes a similar bug in ip_append_page spotted by you :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I added this to net-2.6, thanks Herbert!

I already checked in the ip_append_page() fix to net-2.6 so
I simply removed that hunk when adding your fix.

Thanks again!
