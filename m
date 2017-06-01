From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: route: restore skb_dst_set in
 inet_rtm_getroute
Date: Thu, 01 Jun 2017 11:34:29 -0400 (EDT)
Message-ID: <20170601.113429.1492311634394467957.davem@davemloft.net>
References: <1496296405-61386-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com, dsahern@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55934 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdFAPed (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 11:34:33 -0400
In-Reply-To: <1496296405-61386-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Wed, 31 May 2017 22:53:25 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> recent updates to inet_rtm_getroute dropped skb_dst_set in
> inet_rtm_getroute. This patch restores it because it is
> needed to release the dst correctly.
> 
> Fixes: 3765d35ed8b9 ("net: ipv4: Convert inet_rtm_getroute to rcu versions of route lookup")
> Reported-by: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied.
