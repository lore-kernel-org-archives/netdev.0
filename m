From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Wed, 11 Jun 2014 20:43:29 -0700
Message-ID: <1402544609.3645.473.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	  <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.DEB.2.02.1406101726390.11647@dtop>
	  <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	  <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.DEB.2.10.1406102114520.28698@dinf>
	  <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.DEB.2.02.1406110011170.11647@dtop>
	  <alpine.DEB.2.02.1406110022550.11647@dtop>
	  <alpine.DEB.2.02.1406110036490.11647@dtop>
	  <1402490462.3645.463.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402492373.3645.466.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406111851140.18470@dtop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:59472 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184AbaFLDnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 23:43:32 -0400
Received: by mail-pa0-f52.google.com with SMTP id eu11so522709pac.39
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 20:43:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406111851140.18470@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-11 at 18:55 -0700, dormando wrote:

> I sent the udpkill utility in an off-list mail (in case that got binned by
> anyone).
> 
> Just threw this patch on top of the other two, on 3.10.42. udpkill's been
> running for an hour without fault. I've just put traffic back onto the
> machine am leaving udpkill enabled for a while longer.
> 
> So, this is an improvement :)

Nice. I suspect regression came with 3.6 ip route cache removal, but I
am lazy to point the exact commit.
