From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: check and errout if res->fi is NULL when
 RTM_F_FIB_MATCH is set
Date: Fri, 18 Aug 2017 16:06:23 -0700 (PDT)
Message-ID: <20170818.160623.1816130769638429758.davem@davemloft.net>
References: <1502912332-41154-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, dsa@cumulusnetworks.com,
        idaifish@gmail.com, syzkaller@googlegroups.com, dvyukov@google.com,
        eric.dumazet@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdHRXGY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:06:24 -0400
In-Reply-To: <1502912332-41154-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Wed, 16 Aug 2017 12:38:52 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Syzkaller hit 'general protection fault in fib_dump_info' bug on
> commit 4.13-rc5..
> 
> Guilty file: net/ipv4/fib_semantics.c
 ...
> This patch adds a res->fi NULL check.
> 
> example run:
> $ip route get 0.0.0.0 iif virt1-0
> broadcast 0.0.0.0 dev lo
>     cache <local,brd> iif virt1-0
> 
> $ip route get 0.0.0.0 iif virt1-0 fibmatch
> RTNETLINK answers: No route to host
> 
> Reported-by: idaifish <idaifish@gmail.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Fixes: b61798130f1b ("net: ipv4: RTM_GETROUTE: return matched fib result when requested")
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thank you.
