From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: ip_do_fragment: fix headroom tests
Date: Sat, 15 Jul 2017 14:38:55 -0700 (PDT)
Message-ID: <20170715.143855.2063043330641361274.davem@davemloft.net>
References: <88e7a111-ddcd-5aa9-f15e-045f9b0831a8@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, fw@strlen.de, dwmw2@infradead.org,
        devel@openvz.org
To: vvs@virtuozzo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54568 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbdGOVi4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2017 17:38:56 -0400
In-Reply-To: <88e7a111-ddcd-5aa9-f15e-045f9b0831a8@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@virtuozzo.com>
Date: Fri, 14 Jul 2017 12:04:16 +0300

> Some time ago David Woodhouse reported skb_under_panic
> when we try to push ethernet header to fragmented ipv6 skbs.
> It was fixed for ipv6 by Florian Westphal in
> commit 1d325d217c7f ("ipv6: ip6_fragment: fix headroom tests and skb leak")
> 
> However similar problem still exist in ipv4.
> 
> It does not trigger skb_under_panic due paranoid check
> in ip_finish_output2, however according to Alexey Kuznetsov
> current state is abnormal and ip_fragment should be fixed too.
> 
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>

Applied, thank you.
