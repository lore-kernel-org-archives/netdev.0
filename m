From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: raw PF_PACKET protocol selection
Date: Tue, 9 Oct 2007 08:08:22 +0200
Message-ID: <00ac01c80a3a$cc83a6a0$04ac10ac@Jocke>
References: <E1If5b3-00043F-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Herbert Xu'" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:26173 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751854AbXJIGI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 02:08:26 -0400
In-Reply-To: <E1If5b3-00043F-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
> Sent: den 9 oktober 2007 05:17
> To: joakim.tjernlund@transmode.se
> Cc: netdev@vger.kernel.org
> Subject: Re: raw PF_PACKET protocol selection
> 
> Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:
> > 
> > I trying to open my own raw PF_PACKET socket to receive 
> > pkgs sent to this socket. I can only make ETH_P_ALL protocol
> > work, but then I receive all pkgs and I want pkgs with a specific
> > protocol type. I have tried lots of ETH_P types and none of 
> them work.
> > Naturally I make sure the sender is using the same protocol 
> as my test
> > program below. I guess I must be doing something wrong???
> 
> Your program works fine here.  You did run it as root, right?

Yes and ETH_P_ALL is the only protocol that prints anything
I am on 2.6.22

> Did you try stracing it?

Just did and now it works, it didn't yesterday :(
But if I change protocol to ETH_P_MOBITEX, I don't get any
pkgs(I did change protocol on sending side too)

> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
> 
> 

