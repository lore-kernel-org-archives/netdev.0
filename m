From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net] ipv6: no need to check rt->dst.error when get
 route info
Date: Mon, 31 Jul 2017 16:22:37 -0700 (PDT)
Message-ID: <20170731.162237.142502126102802813.davem@davemloft.net>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
        <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        roopa@cumulusnetworks.com, dsahern@gmail.com
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47352 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdGaXWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 19:22:38 -0400
In-Reply-To: <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Fri, 28 Jul 2017 00:25:36 +0800

> After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
> result when requested"). When we get a prohibit ertry, we will return
> -EACCES directly instead of dump route info.
> 
> Fix it by remove the rt->dst.error check.
...
> Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

David A., where are we on this?
