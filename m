From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bug 12327] New: Intermittent TCP issues with => 2.6.27
Date: Fri, 02 Jan 2009 18:36:03 +1100
Message-ID: <E1LIeZf-0006ET-OY@gondolin.me.apana.org.au>
References: <20081229185544.174fd331@extreme>
Cc: ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org (Stephen Hemminger)
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:40716 "EHLO arnor.apana.org.au"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751624AbZABHiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 02:38:19 -0500
In-Reply-To: <20081229185544.174fd331@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
> A number of websites, ping, traceroute work correctly but I simply can't
> connect to several including:
> 
> - store.apple.com
> - youtube.com
> - ANZ internet banking (anz.com.au)
> - MSN messenger

I failed to reproduce this on 2.6.28-rc9.  I even used the same
IP address as shown in your pcap file, 17.149.156.10.

In fact, your pcap file shows that the two kernels produce almost
exactly the same content in the TCP headers.  The only material
difference was the window size, which differed by 32 bytes.

So I'd suggest you take a look at other nodes on the path between
you and those websites, or try turning things such as window
scaling off.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
