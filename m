From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Tue, 20 Jan 2015 09:40:38 +1100
Message-ID: <20150119224038.GA8854@gondor.apana.org.au>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
 <20141201102522.GA16579@gondor.apana.org.au>
 <20141231133923.GA30248@gondor.apana.org.au>
 <2797327.cCdE9QefP4@storm>
 <CANn89i+U-PFbuUrp08s3Ec8BmjPFq1zj8Aj2=vPVO4-iiLkTuw@mail.gmail.com>
 <20150119223635.GA8735@gondor.apana.org.au>
 <CANn89iLpgUEuHQvyJHR8g3q62-Hi-XfYKeVpLvG__UQLrqR5Bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40675 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbbASWko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 17:40:44 -0500
Content-Disposition: inline
In-Reply-To: <CANn89iLpgUEuHQvyJHR8g3q62-Hi-XfYKeVpLvG__UQLrqR5Bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 02:38:47PM -0800, Eric Dumazet wrote:
> 
> SYN and FIN packets are in the send queue.
> 
> They are valid and might have a zero size.

Right, obviously I meant packets in between the SYN and the FIN.
Technically SYN/FIN are not really zero-sided since they carry
one bit of information and yes they do get cleaned while the ones
in the middle will not.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
