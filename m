From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Mon, 30 Jun 2014 01:30:49 -0700
Message-ID: <1404117049.15139.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	   <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	   <alpine.DEB.2.02.1406101726390.11647@dtop>
	   <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	  <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.DEB.2.02.1406281724370.18954@dtop>
	 <1404110292.15139.42.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406300112340.31629@dtop>
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
Received: from mail-wi0-f173.google.com ([209.85.212.173]:50487 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbaF3Iaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 04:30:55 -0400
Received: by mail-wi0-f173.google.com with SMTP id cc10so5564572wib.12
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 01:30:53 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406300112340.31629@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-30 at 01:15 -0700, dormando wrote:

> Heh. You folks have quite insane amounts of output.
> 
> I'm now testing a kernel which has the one upstreamed patch + the two not
> yet in -stable, under 3.10.45. A kernel with ~60% of those patches has
> been running for 17.5 days so far. Much longer than it normally runs.
> 
> So, looking pretty decent, still. Thanks for your patience for all of my
> dumb questions. I'll probably only pipe up again on this issue if I see
> another crash.

Thanks _you_ for your patience, reports, and tests !
