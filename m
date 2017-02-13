From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/llc: avoid BUG_ON() in skb_orphan()
Date: Sun, 12 Feb 2017 22:15:36 -0500 (EST)
Message-ID: <20170212.221536.1514632035364453264.davem@davemloft.net>
References: <CAAeHK+yzH_M4uzetrMQPMgYBNDXYAp0V11DcMtUgNWVvPg4x=g@mail.gmail.com>
        <CANn89iKww-oSWGWx-PZ_gXYmeFr8NSwJS55vNB=jyaBghTmtvA@mail.gmail.com>
        <1486937032.8227.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, acme@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdBMDPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 22:15:38 -0500
In-Reply-To: <1486937032.8227.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 12 Feb 2017 14:03:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems nobody used LLC since linux-3.12.
> 
> Fortunately fuzzers like syzkaller still know how to run this code,
> otherwise it would be no fun.
> 
> Setting skb->sk without skb->destructor leads to all kinds of
> bugs, we now prefer to be very strict about it.
> 
> Ideally here we would use skb_set_owner() but this helper does not exist yet,
> only CAN seems to have a private helper for that.
> 
> Fixes: 376c7311bdb6 ("net: add a temporary sanity check in skb_orphan()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks Eric.
