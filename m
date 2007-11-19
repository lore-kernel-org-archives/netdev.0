From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Mon, 19 Nov 2007 12:41:17 +0800
Message-ID: <20071119044117.GA1880@gondor.apana.org.au>
References: <p73bq9tau2x.fsf@bingen.suse.de> <20071117.160926.232024605.davem@davemloft.net> <20071118214515.GA8161@one.firstfloor.org> <20071118.144010.236028466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3068 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753995AbXKSElp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 23:41:45 -0500
Content-Disposition: inline
In-Reply-To: <20071118.144010.236028466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 18, 2007 at 02:40:10PM -0800, David Miller wrote:
>
> This can be fixed, the above cannot.

That's a good point.  Perhaps one way of getting that info to
the user without putting it in UDPInDatagrams is to create an
inet_diag interface for UDP and put the number of queued packets
for each socket in it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
