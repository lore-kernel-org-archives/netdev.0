From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SCTP performance?
Date: Fri, 09 Aug 2013 16:21:58 -0700
Message-ID: <1376090518.20509.14.camel@edumazet-glaptop>
References: <52057734.6060306@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:45420 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031447Ab3HIXV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 19:21:59 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so4980788pbc.8
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 16:21:59 -0700 (PDT)
In-Reply-To: <52057734.6060306@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-09 at 16:11 -0700, Ben Greear wrote:
> I just added some support for SCTP to my traffic-generator tool.
> 
> I tried to send 1Gbps of traffic, bi-directional, across two
> 10G interfaces.  TCP does this without any trouble at all,
> but SCTP was asymetric and never got above around 700Mbps,
> and was usually stuck at < 500Mbps.
> 
> perf top didn't show any obvious CPU bottlenecks.
> 
> Has anyone done any recent performance testing with SCTP?
> 
> I'd be interested to know the results if so...

You mean there is no SCTP offload on the NIC and/or GRO, yes that's too
bad.
