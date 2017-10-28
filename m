From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] tcp: refresh tp timestamp before tcp_mtu_probe()
Date: Sat, 28 Oct 2017 19:17:58 +0900 (KST)
Message-ID: <20171028.191758.969563599419041416.davem@redhat.com>
References: <1509078100.11887.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37892 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750930AbdJ1KSH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 06:18:07 -0400
In-Reply-To: <1509078100.11887.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Oct 2017 21:21:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In the unlikely event tcp_mtu_probe() is sending a packet, we
> want tp->tcp_mstamp being as accurate as possible. 
> 
> This means we need to call tcp_mstamp_refresh() a bit earlier in
> tcp_write_xmit().
> 
> Fixes: 385e20706fac ("tcp: use tp->tcp_mstamp in output path")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
