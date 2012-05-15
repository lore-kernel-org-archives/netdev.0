From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 15 May 2012 17:47:34 +0100
Message-ID: <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16594 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757470Ab2EOQri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 12:47:38 -0400
In-Reply-To: <1337099641.8512.1102.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-15 at 18:34 +0200, Eric Dumazet wrote:
> On Tue, 2012-05-15 at 17:29 +0100, Kieran Mansley wrote:
> > On Tue, 2012-05-15 at 16:56 +0200, Eric Dumazet wrote:
> > > 
> > > Please try latest kernels, this is probably 'fixed'
> > 
> > I've just tried with 3.4.0-rc7 and the problem is still reproducible.
> > It's perhaps harder to reproduce than on 3.3.6 but still there.
> > 
> > > What network driver are you using ? 
> > 
> > The receiver is using the sfc driver that is included in the kernel
> > build, together with an SFC 9020 NIC. 
> > 
> > Kieran
> > 
> 
> MTU ?

1500

> What is typical skb->truesize of skb given to stack in RX path ?
>
> If drivers use PAGE_SIZE fragments, then you are more likely to hit
> limit.

We're passing page fragments into GRO.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
