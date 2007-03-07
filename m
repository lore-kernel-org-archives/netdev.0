From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink recvmsg() and MSG_TRUNC
Date: Wed, 7 Mar 2007 11:04:58 +1100
Message-ID: <20070307000458.GB13170@gondor.apana.org.au>
References: <20070306.151953.112290310.davem@davemloft.net> <E1HOjP1-0003NM-00@gondolin.me.apana.org.au> <20070306155750.7827ab1d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3121 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030749AbXCGAFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 19:05:07 -0500
Content-Disposition: inline
In-Reply-To: <20070306155750.7827ab1d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 03:57:50PM -0800, Stephen Hemminger wrote:
> 
> I know some commands send big blocks down of configuration information.
> One example is netem statistical data, but there are others.

You mean dumps? Unless someone is coalescing them I don't see a problem
there.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
