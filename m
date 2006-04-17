From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: fixing sk_stream_rfree()
Date: Mon, 17 Apr 2006 16:17:00 +1000
Message-ID: <20060417061700.GA21709@gondor.apana.org.au>
References: <20060414.205927.13626300.davem@davemloft.net> <20060416111831.GA15093@gondor.apana.org.au> <20060416.223203.47773632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:24328 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750704AbWDQGRD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 02:17:03 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060416.223203.47773632.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 16, 2006 at 10:32:03PM -0700, David S. Miller wrote:
> 
> Let me save you some time, later in the thread you'll find
> out that this whole thing is a dead end.

Thanks.  I even read the message but managed to miss your conclusion :)

> So it nearly has to be a send side issue that can only trigger with
> TSO enabled, and my next planned chore is to audit the TSO splitting
> during ACK processing.  We may be doing something stupid there.

BTW, do we have a dmesg log from the machine that did this with tg3?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
