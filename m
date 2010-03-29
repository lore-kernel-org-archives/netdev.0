From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 16:40:18 +0800
Message-ID: <20100329084018.GA22547@gondor.apana.org.au>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi> <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:38612 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754556Ab0C2Ik1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 04:40:27 -0400
Content-Disposition: inline
In-Reply-To: <20100325.122611.267401605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 25, 2010 at 12:26:11PM -0700, David Miller wrote:
>
> Maybe we can make the dead state check safe to do asynchronously
> somehow?  I wonder if the policy layer is overdue for an RCU
> conversion or similar.

In fact, now that I read this again, we don't even need to grab
the lock to perform the deadness check.  This is because the
existing never did it anyway.  The liveliness is guaranteed by
the policy destruction code doing a synchronous cache flush.

Timo, what was the reason for getting rid of the synchronous
flush again?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
