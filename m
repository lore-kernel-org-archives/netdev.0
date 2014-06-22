From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Sun, 22 Jun 2014 12:07:22 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406221202460.14871@dtop>
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
Received: from rydia.net ([69.46.88.68]:55214 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbaFVTHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jun 2014 15:07:25 -0400
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
>

Update on testing:

I only have two machines that crash on their own frequently (more like
one, even). Unfortunately something happened to the datacenter it's in and
it was offline for a week. The machine normally crashes after 1.5-4d,
averaging 2d.

It's done about three days total time without a new crash. I also have the
kernel running in another datacenter for ~10 days.. but it takes 30-150
days to crash in that one.

So, inconclusive, but still promising. If the machine survives the week it
probably means it's fixed, or at least greatly reduced.

I saw that one of your patches got queued for stable, but all three were
necessary to fix udpkill. What's your plan for cleanup/upstreaming?

Did you folks end up running udpkill under the tester thing?

thanks,
-Dormando
