From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: raw PF_PACKET protocol selection
Date: Tue, 09 Oct 2007 11:17:25 +0800
Message-ID: <E1If5b3-00043F-00@gondolin.me.apana.org.au>
References: <1191868569.6682.67.camel@gentoo-jocke.transmode.se>
Cc: netdev@vger.kernel.org
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1139 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753180AbXJIDRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 23:17:33 -0400
In-Reply-To: <1191868569.6682.67.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:
> 
> I trying to open my own raw PF_PACKET socket to receive 
> pkgs sent to this socket. I can only make ETH_P_ALL protocol
> work, but then I receive all pkgs and I want pkgs with a specific
> protocol type. I have tried lots of ETH_P types and none of them work.
> Naturally I make sure the sender is using the same protocol as my test
> program below. I guess I must be doing something wrong???

Your program works fine here.  You did run it as root, right?
Did you try stracing it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
