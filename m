From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 17:48:54 -0500 (EST)
Message-ID: <20170227.174854.1727197935165904806.davem@davemloft.net>
References: <20170227141403.714490f7@xeon-e3>
        <1488234917.9415.217.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170227144455.174ab1e5@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51144 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdB0XnR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 18:43:17 -0500
In-Reply-To: <20170227144455.174ab1e5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 27 Feb 2017 14:44:55 -0800

> On Mon, 27 Feb 2017 14:35:17 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> On Mon, 2017-02-27 at 14:14 -0800, Stephen Hemminger wrote:
>> 
>> > The original design (as Davem mentioned) was that IRQ's must be disabled
>> > during device polling. If that was true, then the race above
>> > would be impossible.  
>> 
>> I would love to see an alternative patch.
> 
> Turn off busy poll? 
> The poll stuff runs risk of breaking more things.

Eric is exactly trying to make busy poll even more prominent in
the stack, not less prominent.

It's an important component of some performance improvements he is
working on.
