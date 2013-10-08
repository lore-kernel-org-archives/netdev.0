From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: gro: allow to build full sized skb
Date: Tue, 08 Oct 2013 09:50:42 -0700
Message-ID: <1381251042.12191.56.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381248143.12191.53.camel@edumazet-glaptop.roam.corp.google.com>
	 <52542F77.2050308@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:35033 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755504Ab3JHQun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 12:50:43 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so8896614pbc.12
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 09:50:43 -0700 (PDT)
In-Reply-To: <52542F77.2050308@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-08 at 09:14 -0700, Ben Greear wrote:

> On multi-homed boxes you could easily have paths that would never need linearize
> and other paths that always need it, for whatever reason.
> 
> Maybe a per-netdev check for needs linearize instead of something global
> would be better...and maybe let users over-ride the default behaviour
> regardless?

Sure. Note that this has yet to be discussed.

I mentioned this in the changelog for completeness.

I know people just disabling GRO in forwarding setups, probably because
we lack control of latencies / bursts.
