From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp cache
Date: Wed, 15 Mar 2017 15:59:01 -0700
Message-ID: <1489618741.28631.172.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
         <20170315.154044.170788541865531834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: soheil.kdev@gmail.com, netdev@vger.kernel.org, soheil@google.com,
        edumazet@google.com, ncardwell@google.com, ycheng@google.com,
        lvml@5t9.de, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35600 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754318AbdCOW7J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:59:09 -0400
Received: by mail-pg0-f68.google.com with SMTP id g2so3720735pge.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 15:59:08 -0700 (PDT)
In-Reply-To: <20170315.154044.170788541865531834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-15 at 15:40 -0700, David Miller wrote:
> From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
> Date: Wed, 15 Mar 2017 16:30:45 -0400
> 
> > Note that this cache was already broken for caching timestamps of
> > multiple machines behind a NAT sharing the same address.
> 
> That's the documented, well established, limitation of time-wait
> recycling.
> 
> People who enable it, need to consider this issue.
> 
> This limitation of the feature does not give us a reason to break the
> feature even further as a matter of convenience, or to remove it
> altogether for the same reason.
> 
> Please, instead, fix the bug that was introduced.
> 
> Thank you.

You mean revert Florian nice patches ?

This would kill timestamps randomization, and thus prevent some
organizations to turn TCP timestamps on.

TCP timestamps are more useful than this obscure tw_recycle thing that
is hurting innocent users.
