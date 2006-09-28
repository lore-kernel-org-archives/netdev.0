From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6]: Disable SG for GSO unless we have checksum
Date: Wed, 27 Sep 2006 19:05:04 -0700 (PDT)
Message-ID: <20060927.190504.94890345.davem@davemloft.net>
References: <20060928004422.GA9050@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62443
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965196AbWI1CFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 22:05:05 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060928004422.GA9050@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 28 Sep 2006 10:44:23 +1000

> [IPV6]: Disable SG for GSO unless we have checksum
> 
> Because the system won't turn off the SG flag for us we
> need to do this manually on the IPv6 path.  Otherwise we
> will throw IPv6 packets with bad checksums at the hardware.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and pushed to -stable for 2.6.18.y, thanks a lot
Herbert.
