From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp cache
Date: Wed, 15 Mar 2017 23:55:08 +0100
Message-ID: <20170315225508.GB14761@1wt.eu>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
 <20170315.154044.170788541865531834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: soheil.kdev@gmail.com, netdev@vger.kernel.org, soheil@google.com,
        edumazet@google.com, ncardwell@google.com, ycheng@google.com,
        lvml@5t9.de, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:32308 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752101AbdCOW4U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 18:56:20 -0400
Content-Disposition: inline
In-Reply-To: <20170315.154044.170788541865531834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Mar 15, 2017 at 03:40:44PM -0700, David Miller wrote:
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

At least I can say I've seen many people enable it without understanding
its impact, confusing it with tcp_tw_reuse, and copy-pasting it from
random blogs and complaining about issues in production.

I agree that it's hard to arbiter between stupidity and flexibility
though :-/

Regards,
Willy
