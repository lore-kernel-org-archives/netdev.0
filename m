From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Remove use of inet6_sk and add IPv6
 checks to tracepoint
Date: Fri, 20 Oct 2017 13:05:24 +0100 (WEST)
Message-ID: <20171020.130524.1057906504749935063.davem@davemloft.net>
References: <1508339849-19527-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, songliubraving@fb.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752874AbdJTMF2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 08:05:28 -0400
In-Reply-To: <1508339849-19527-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 18 Oct 2017 08:17:29 -0700

> 386fd5da401d ("tcp: Check daddr_cache before use in tracepoint") was the
> second version of the tracepoint fixup patch. This patch is the delta
> between v2 and v3.  Specifically, remove the use of inet6_sk and check
> sk_family as requested by Eric and add IS_ENABLED(CONFIG_IPV6) around
> the use of sk_v6_rcv_saddr and sk_v6_daddr as done in sock_common (noted
> by Cong).
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied, sorry for the mixup :)
