From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 03 Nov 2015 11:49:16 -0800
Message-ID: <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
	 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33130 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932456AbbKCTtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 14:49:17 -0500
Received: by pabfh17 with SMTP id fh17so27218427pab.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 11:49:17 -0800 (PST)
In-Reply-To: <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-03 at 21:17 +0200, Denys Fedoryshchenko wrote:
>  GSO/TSO on the output and watch performance coming back.
> 
> It is not, since i have more than 120 servers installed over country 
> (most of them handle small traffic), in forwarding mode, first thing i 
> am doing on forwarding setup - disabling gro/gso/tso. It is helped also 
> many ISP on their forum where i visit often, first thing in 
> troubleshooting unreliable network traffic forwarding - disabling 
> offloading.
> Because problem starts from incorrect shaping, and ends in some cases 
> with network drivers spitting watchdog errors. Sometimes even shaper not 
> necessary, just plain forwarding with offload enabled can cause issues, 
> but it might be bug in networking drivers.
> Should i try to reproduce and report? Sure if anybody can look into this 
> issue.


Well, I am telling you.

Say no to people advising to turn off GRO/TSO.

If you were the guy adviding others to do so, it is time to see the
light.

Lets fix the bugs if any, instead of spreading disinformation.

I am so tired of telling these very simple facts guys.

If you prefer, continue to work on linux-2.0 but don't ask help on
netdev.
