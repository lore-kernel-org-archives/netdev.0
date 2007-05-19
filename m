From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Purpose of bit shifts in tcp_get_info
Date: Sat, 19 May 2007 15:22:47 +1000
Message-ID: <E1HpHOx-0001JW-00@gondolin.me.apana.org.au>
References: <21FCA9FF-08FB-4C6F-B2C5-669E36A7748C@mac.com>
Cc: netdev@vger.kernel.org
To: daniel.schaffrath@mac.com (Daniel Schaffrath)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2414 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755525AbXESFWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 01:22:54 -0400
In-Reply-To: <21FCA9FF-08FB-4C6F-B2C5-669E36A7748C@mac.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Schaffrath <daniel.schaffrath@mac.com> wrote:
> 
> I was wondering what the purpose of the bit shifts in tcp_get_info  
> right after the jiffies conversion might be. What's the time unit  
> after that shift?
> 
>         info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
>         info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;
> [...]
>         info->tcpi_rcv_rtt = jiffies_to_usecs(tp->rcv_rtt_est.rtt)>>3;
> 
> Maybe somebody has a hint for me?

Checkout the comment in tcp_rtt_estimator() in net/ipv4/tcp_input.c.
It's commented in the actual struct too for srtt at least.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
