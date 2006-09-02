From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: icmp echo reply and DF
Date: Sat, 02 Sep 2006 12:41:12 +1000
Message-ID: <E1GJLRY-0006OB-00@gondolin.me.apana.org.au>
References: <BAY103-F80FA7B64C2360B1CFF28BB23C0@phx.gbl>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39943 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750699AbWIBClK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 22:41:10 -0400
To: pupilla@hotmail.com (Marco Berizzi)
In-Reply-To: <BAY103-F80FA7B64C2360B1CFF28BB23C0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi <pupilla@hotmail.com> wrote:
> I kindly would like to know why linux reply to ICMP
> echo request packets with the DF bit set always to 0.

We do that because that's the only sensible thing to do if you
actually want ICMP messages to reach the destination host.  PMTU
on ICMP does not make sense.

Furthermore, ICMP echo means echoing at the ICMP level, it does
not mean that we have to echo things inside the IP header.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
VGER BF report: U 0.5
