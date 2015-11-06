From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: NETIF_F_GSO_SOFTWARE vs NETIF_F_GSO
Date: Fri, 6 Nov 2015 12:58:42 +0800
Message-ID: <20151106045842.GB14722@gondor.apana.org.au>
References: <CAHmME9rGvViDN2iFa8xfXvUJpQThJnrCcZ1yHgQrdgEQRUWtfg@mail.gmail.com>
 <20151105121501.GA5776@gondor.apana.org.au>
 <CAHmME9pP1E64CCc7+XW8X1duYGQZdYj9s_r8UNq3KMh6xey_Hw@mail.gmail.com>
 <1446738967.4184.35.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAHmME9ptruMW4MFZ1q3=tgTANro1_CdwnCWS5O_0_WwbFKgUAw@mail.gmail.com>
 <CAHmME9ruZb=F+Nv5BqfS+9gEL4FriCgGkaD6Pvy2iD1FXv0EQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:39348 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030793AbbKFE6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 23:58:45 -0500
Content-Disposition: inline
In-Reply-To: <CAHmME9ruZb=F+Nv5BqfS+9gEL4FriCgGkaD6Pvy2iD1FXv0EQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 06, 2015 at 02:31:59AM +0100, Jason A. Donenfeld wrote:
> 
> So far implementing (3) is failing miserably. Is there anything wrong
> with my general idea that might make this a priori impossible? For
> example, will udp_tunnel_xmit_skb not accept super-packets? Or, am I
> just not making use of whatever nice convenience functions are
> available for constructing super-packets, and thus am doing something
> wrong?

I don't see anything fundamentally wrong with your idea.  After
all what you're describing is the basis of GSO, i.e., letting
data stay in the form of super-packets for as long as we can.

Of course there's going to be a lot of niggly bits that you'll
have to sort out to get it to work.

Good luck,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
