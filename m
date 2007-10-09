From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: raw PF_PACKET protocol selection
Date: Tue, 9 Oct 2007 15:56:43 +0800
Message-ID: <20071009075643.GA17588@gondor.apana.org.au>
References: <E1If5b3-00043F-00@gondolin.me.apana.org.au> <00ac01c80a3a$cc83a6a0$04ac10ac@Jocke> <20071009071338.GA15057@2ka.mipt.ru> <1191914858.6682.75.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2312 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751600AbXJIH46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 03:56:58 -0400
Content-Disposition: inline
In-Reply-To: <1191914858.6682.75.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 09, 2007 at 09:27:38AM +0200, Joakim Tjernlund wrote:
>
> Just fond out something:
> if I redirect my prog like so:
> ./sniff > log
> and press Ctrl-C after a packet has been sent to it, 
> it does NOT work. I don't get ANY output in my "log" file, not
> even the printf("---------\n") appears.
> But if I run whithout redirect it works(at least with ETH_P_BPQ)
> Anyone else see this too?

Um, this is what we call buffering.

You either need to turn buffering off with setbuf(3) or you
should install a SIGINT handler to flush the output before
exiting.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
