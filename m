From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2] ipv6: ignore null_entry in inet6_rtm_getroute()
 too
Date: Thu, 02 Mar 2017 14:36:49 -0800 (PST)
Message-ID: <20170302.143649.1303630232040429807.davem@davemloft.net>
References: <1488430119-4670-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, dsa@cumulusnetworks.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39986 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751035AbdCBXyi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 18:54:38 -0500
In-Reply-To: <1488430119-4670-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed,  1 Mar 2017 20:48:39 -0800

> Like commit 1f17e2f2c8a8 ("net: ipv6: ignore null_entry on route dumps"),
> we need to ignore null entry in inet6_rtm_getroute() too.
> 
> Return -ENETUNREACH here to sync with IPv4 behavior, as suggested by David.
> 
> Fixes: a1a22c1206 ("net: ipv6: Keep nexthop of multipath route on admin down")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
