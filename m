From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [IPv6] SNMP: Restore Udp6InErrors incrementation
Date: Thu, 1 Nov 2007 23:05:00 +0800
Message-ID: <20071101150500.GB7965@gondor.apana.org.au>
References: <20071101224638.b954a697.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4962 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756698AbXKAPQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 11:16:16 -0400
Content-Disposition: inline
In-Reply-To: <20071101224638.b954a697.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 01, 2007 at 10:46:38PM +0900, Mitsuru Chinen wrote:
> As the checksum verification is postponed till user calls recv or poll,
> the inrementation of Udp6InErrors counter should be also postponed.
> Currently, it is postponed in non-blocking operation case. However it
> should be postponed in all case like the IPv4 code.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Looks good to me.  Thanks for catching this!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
