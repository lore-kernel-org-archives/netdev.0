From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 18:47:52 +0100
Message-ID: <1272304072.2376.10.camel@achroite.uk.solarflarecom.com>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
	 <1272302434.19143.76.camel@edumazet-laptop>
	 <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25782 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210Ab0DZRr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 13:47:56 -0400
In-Reply-To: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-04-26 at 10:38 -0700, Tom Herbert wrote:
> > Hi Tom
> >
> > I tested this rxhash feature on my bnx2x card, using latest net-next-2.6
> > and appropriate ethtool
> >
> > ethtool -k eth1 rxhash on
> >
> > Then I used my pktgen script, to flood machine with flows with udp dst
> > port varying between 4000 and 4015.
> >
> > Software generated rxhash is OK (16 different values).
> >
> > But with bnx2x provided hash, all skb were hashed to same rxhash
> > value :(
> >
> > What are the specs of this hardware hash ?
> > It seems to not care of udp source/destination ports.
> >
> 
> It would appear that way :-(.  I was going to ping Broadcom folks to
> see if there's support for UDP.
[...]

Unfortunately the widely-implemented Toeplitz hash functions are defined
only for TCP/IPv4, TCP/IPv6, IPv4 and IPv6.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

