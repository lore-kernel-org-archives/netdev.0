From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Mon, 28 Nov 2016 15:40:57 -0500 (EST)
Message-ID: <20161128.154057.1355209532933900181.davem@davemloft.net>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
        <CALzJLG8nFBFy=-pjy-XBYb-y-F=grC5wjN35zTt9eUOT-612Eg@mail.gmail.com>
        <1480212960.18162.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@dev.mellanox.co.il, netdev@vger.kernel.org,
        tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753688AbcK1Uk6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:40:58 -0500
In-Reply-To: <1480212960.18162.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 26 Nov 2016 18:16:00 -0800

> On Sun, 2016-11-27 at 00:47 +0200, Saeed Mahameed wrote:
>> On Fri, Nov 25, 2016 at 5:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> As you see here in SRIOV mode (PF only) reads   sw stats from FW.
>> Tariq, I think we need to fix this.
> 
> Sure, my patch does not change this at all.
> 
> If mlx4_is_master() is false, then we aggregate the software states and
> only the software stats.
> 
> My patch makes this aggregation possible at the time ethtool or
> ndo_get_stat64() are called, since this absolutely not depend on the 250
> ms timer fetching hardware stats.

Saeed please provide counter arguments or ACK this patch, thank you.
