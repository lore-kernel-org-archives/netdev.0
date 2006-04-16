From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: fixing sk_stream_rfree()
Date: Sun, 16 Apr 2006 21:18:31 +1000
Message-ID: <20060416111831.GA15093@gondor.apana.org.au>
References: <20060414.205927.13626300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:8710 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750715AbWDPLSe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 07:18:34 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060414.205927.13626300.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David:

I've been flying on and off for the last two days so I only saw this now.

On Fri, Apr 14, 2006 at 08:59:27PM -0700, David S. Miller wrote:
> 
> Herbert, as you may have noticed we found some missing
> locking in sk_stream_rfree().  It could explain the
> "!sk_forward_alloc" BUG() we thought was caused by e1000's
> TSO implementation and the Intel folks have provided enough
> datapoints to prove that it is indeed not an e1000 specific
> problem.

Great eyes! Yes that bug seems to have been around forever.  I'll
look over the patch tomorrow as right now I'm still on west-coast
time :)

I have one niggling doubt though as to why turning off TSO seems
to cure the problem for people.  Perhaps it'll become clearer
tomorrow morning when I look at it again :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
