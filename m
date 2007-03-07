From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink recvmsg() and MSG_TRUNC
Date: Wed, 7 Mar 2007 11:04:19 +1100
Message-ID: <20070307000419.GA13170@gondor.apana.org.au>
References: <20070306.151953.112290310.davem@davemloft.net> <E1HOjP1-0003NM-00@gondolin.me.apana.org.au> <20070306.160202.102574506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3112 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030748AbXCGAEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 19:04:21 -0500
Content-Disposition: inline
In-Reply-To: <20070306.160202.102574506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 04:02:02PM -0800, David Miller wrote:
>
> Create a lot of intefaces, try to dump them :-)

Dumps should be done using 4K (NLMSG_GOODSIZE) skb's, where is the problem?

> GLIBC can even hit this via it's ifaddrs.c code.

Do you have a simple test case that I can run?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
