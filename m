From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6: reorder icmpv6_init() and ip6_mr_init()
Date: Tue, 07 Mar 2017 14:57:54 -0800 (PST)
Message-ID: <20170307.145754.1808918146000265149.davem@davemloft.net>
References: <1488746093-3529-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751507AbdCGW72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:59:28 -0500
In-Reply-To: <1488746093-3529-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sun,  5 Mar 2017 12:34:53 -0800

> Andrey reported the following kernel crash:
...
> This is because net->ipv6.mr6_tables is not initialized at that point,
> ip6mr_rules_init() is not called yet, therefore on the error path when
> we iterator the list, we trigger this oops. Fix this by reordering
> ip6mr_rules_init() before icmpv6_sk_init().
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
