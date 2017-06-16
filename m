From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Fri, 16 Jun 2017 12:02:11 -0400 (EDT)
Message-ID: <20170616.120211.938246180659777930.davem@davemloft.net>
References: <1497493770-13000-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <1497493770-13000-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, pshelar@ovn.org, ast@fb.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdFPQCO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:02:14 -0400
In-Reply-To: <1497493770-13000-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Thu, 15 Jun 2017 10:29:30 +0800

> When __ip6_tnl_rcv fails, the tun_dst won't be freed, so call
> dst_release to free it in error code path.
> 
> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
> CC: Alexei Starovoitov <ast@fb.com>
> Tested-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
