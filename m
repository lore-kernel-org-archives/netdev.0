From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: send NS for DAD when link
 operationally up
Date: Sat, 30 Sep 2017 05:26:23 +0100 (WEST)
Message-ID: <20170930.052623.1575396130505189058.davem@davemloft.net>
References: <1506373296-24977-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39992 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbdI3E0d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 00:26:33 -0400
In-Reply-To: <1506373296-24977-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Mon, 25 Sep 2017 22:01:36 +0100

> The NS for DAD are sent on admin up as long as a valid qdisc is found.
> A race condition exists by which these packets will not egress the
> interface if the operational state of the lower device is not yet up.
> The solution is to delay DAD until the link is operationally up
> according to RFC2863. Rather than only doing this, follow the existing
> code checks by deferring IPv6 device initialization altogether. The fix
> allows DAD on devices like tunnels that are controlled by userspace
> control plane. The fix has no impact on regular deployments, but means
> that there is no IPv6 connectivity until the port has been opened in
> the case of port-based network access control, which should be
> desirable.
> 
> Signed-off-by: Mike Manning <mmanning@brocade.com>

Applied, thank you.
