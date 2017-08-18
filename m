From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: reset fn->rr_ptr when replacing route
Date: Fri, 18 Aug 2017 16:04:38 -0700 (PDT)
Message-ID: <20170818.160438.850095067230428660.davem@davemloft.net>
References: <20170816181809.37073-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34504 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbdHRXEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:04:39 -0400
In-Reply-To: <20170816181809.37073-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Wed, 16 Aug 2017 11:18:09 -0700

> From: Wei Wang <weiwan@google.com>
> 
> syzcaller reported the following use-after-free issue in rt6_select():
 ...
> The root cause of it is that in fib6_add_rt2node(), when it replaces an
> existing route with the new one, it does not update fn->rr_ptr.
> This commit resets fn->rr_ptr to NULL when it points to a route which is
> replaced in fib6_add_rt2node().
> 
> Fixes: 27596472473a ("ipv6: fix ECMP route replacement")
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
