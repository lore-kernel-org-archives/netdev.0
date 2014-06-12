From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Wed, 11 Jun 2014 21:05:43 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1406112102500.7354@dinf>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>   <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>   <alpine.DEB.2.02.1406101726390.11647@dtop>   <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>   <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>   <alpine.DEB.2.10.1406102114520.28698@dinf>   <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>  
 <alpine.DEB.2.02.1406110011170.11647@dtop>   <alpine.DEB.2.02.1406110022550.11647@dtop>   <alpine.DEB.2.02.1406110036490.11647@dtop>   <1402490462.3645.463.camel@edumazet-glaptop2.roam.corp.google.com>  <1402492373.3645.466.camel@edumazet-glaptop2.roam.corp.google.com>
  <alpine.DEB.2.02.1406111851140.18470@dtop> <1402544609.3645.473.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:55581 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795AbaFLEFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2014 00:05:48 -0400
In-Reply-To: <1402544609.3645.473.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jun 2014, Eric Dumazet wrote:

> On Wed, 2014-06-11 at 18:55 -0700, dormando wrote:
>
> > I sent the udpkill utility in an off-list mail (in case that got binned by
> > anyone).
> >
> > Just threw this patch on top of the other two, on 3.10.42. udpkill's been
> > running for an hour without fault. I've just put traffic back onto the
> > machine am leaving udpkill enabled for a while longer.
> >
> > So, this is an improvement :)
>
> Nice. I suspect regression came with 3.6 ip route cache removal, but I
> am lazy to point the exact commit.
>

Think I owe you a keg at this point. I'll let this bake and we'll see if
the other crashes come back... it'll take a week or two.

I'll have to circle back around to figure out what's gone wrong with 3.14.

Please let me know if there's anything else to test.
