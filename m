From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp: allow busy_poll on some unconnected sockets
Date: Thu, 10 Apr 2014 12:04:09 -0700
Message-ID: <1397156649.16584.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53455581.7060209@solarflare.com>
	  <20140409145129.GA4002@sbohrermbp13-local.rgmadvisors.com>
	  <53457334.1030602@solarflare.com>
	  <alpine.LFD.2.03.1404101856170.27143@solarflare.com>
	 <1397154745.16584.42.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5346E520.7080007@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shawn Bohrer <shawn.bohrer@gmail.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Jonathan Cooper <jcooper@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:61815 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbaDJTEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 15:04:10 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so4238739pdi.16
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 12:04:10 -0700 (PDT)
In-Reply-To: <5346E520.7080007@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-10 at 19:38 +0100, Edward Cree wrote:
> On 10/04/14 19:32, Eric Dumazet wrote:
> > On Thu, 2014-04-10 at 19:04 +0100, Edward Cree wrote:
> >
> >> Tested by setting IFF_SINGLE_NAPI in sfc; a UDP ping-pong test showed a
> >>  performance benefit from sysctl net.core.busy_{read,poll}=50 in both the
> >>  connected and unconnected case, where previously it only saw the benefit
> >>  when the socket had been connected.
> > Right, but how often do we have single NAPI devices on hosts wanting
> > very low latencies ?
> >
> Well, sfc only has a single NAPI context per device, and I'm fairly sure
> most sfc users want very low latencies.
> Or have I misunderstood?

sfc is multi queue/channel, but has a single NAPI instance ?

Sounds wierd.

Please explain me, how GRO can be efficient.

I believe you have one napi per channel.
