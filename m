From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Thu, 2 Sep 2010 12:18:43 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D0670F8@nsmail.netscout.com>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com><1283356463.2556.351.camel@edumazet-laptop><AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com><20100901.183251.106803238.davem@davemloft.net> <20100901185627.239ad165@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <therbert@google.com>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og103.obsmtp.com ([64.18.1.185]:37099 "HELO
	exprod6og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753196Ab0IBQSq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 12:18:46 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100901185627.239ad165@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Just to be contrarian :-) This same idea had started before when IBM
> proposed a user-space NUMA API.  It never got any traction, the
concept
> of "lets make the applications NUMA aware" never got accepted because
> it is so hard to do right and fragile that it was the wrong idea
> to start with. The only people that can manage it are the engineers
> tweeking a one off database benchmark.
> 

If you design an appliance then this would be one of the knobs that
people tinker with. To reap the actual benefits the whole stack(from
adapter's f/w to the userland-thread) needs to be astro-aligned. Almost
all the user-space guys that I've talked to never got it right because
they never understood the concepts behind NUMA-IOH-Mempolicy-MSI-X etc. 
So it's a little difficult for them to get it right the first time.
Also, Stoakley/Nehalem rigs got into mainstream ~2-3 years back? Before
that only a handful of engineers could experiment because the mobo's
were expensive. Plus, you didn't really have 10G fabric then.

Chetan




