From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_gre: only increase err_count for some certain
 type icmpv6 in ip6gre_err
Date: Fri, 27 Oct 2017 23:47:32 +0900 (KST)
Message-ID: <20171027.234732.1412779840678874371.davem@davemloft.net>
References: <70a53e892e143549ea989dc286eba117113d6101.1509017007.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, xeb@mail.ru
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50614 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdJ0Orh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:37 -0400
In-Reply-To: <70a53e892e143549ea989dc286eba117113d6101.1509017007.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 26 Oct 2017 19:23:27 +0800

> The similar fix in patch 'ipip: only increase err_count for some
> certain type icmp in ipip_err' is needed for ip6gre_err.
> 
> In Jianlin's case, udp netperf broke even when receiving a TooBig
> icmpv6 packet.
> 
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.
