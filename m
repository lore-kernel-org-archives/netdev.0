From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Remove redundant RTA_OIF in multipath routes
Date: Thu, 09 Mar 2017 13:07:24 -0800 (PST)
Message-ID: <20170309.130724.2129937577049742239.davem@davemloft.net>
References: <1488844651-12737-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44294 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750913AbdCIVHb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 16:07:31 -0500
In-Reply-To: <1488844651-12737-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon,  6 Mar 2017 15:57:31 -0800

> Dinesh reported that RTA_MULTIPATH nexthops are 8-bytes larger with IPv6
> than IPv4. The recent refactoring for multipath support in netlink
> messages does discriminate between non-multipath which needs the OIF
> and multipath which adds a rtnexthop struct for each hop making the
> RTA_OIF attribute redundant. Resolve by adding a flag to the info
> function to skip the oif for multipath.
> 
> Fixes: beb1afac518d ("net: ipv6: Add support to dump multipath routes
>        via RTA_MULTIPATH attribute")
> Reported-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
