From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ping: do not abuse udp_poll()
Date: Sun, 04 Jun 2017 22:58:17 -0400 (EDT)
Message-ID: <20170604.225817.1212735449685985957.davem@davemloft.net>
References: <20170603051742.m6jtztnn4b3me2co@sasha-lappy>
        <CANn89iKFcPwzVP_gfwkLND9ZTo-+PF8Ex1uePqaawTaLF=Qzmg@mail.gmail.com>
        <1496507365.5031.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, lorenzo@google.com, segoon@openwall.com,
        solar@openwall.com, alexander.levin@verizon.com, pabeni@redhat.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55262 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751279AbdFEC6U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 22:58:20 -0400
In-Reply-To: <1496507365.5031.16.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 03 Jun 2017 09:29:25 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Alexander reported various KASAN messages triggered in recent kernels 
> 
> The problem is that ping sockets should not use udp_poll() in the first
> place, and recent changes in UDP stack finally exposed this old bug.
> 
> Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
> Fixes: 6d0bfe226116 ("net: ipv6: Add IPv6 support to the ping socket.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Sasha Levin <alexander.levin@verizon.com>

Applied and queued up for -stable.
