From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] mpls: Packet stats
Date: Tue, 17 Jan 2017 14:39:08 -0500 (EST)
Message-ID: <20170117.143908.250498954726462201.davem@davemloft.net>
References: <1484331253-5908-1-git-send-email-rshearma@brocade.com>
        <1484576197-19442-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
        ebiederm@xmission.com, roopa@cumulusnetworks.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41992 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750924AbdAQTjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:39:10 -0500
In-Reply-To: <1484576197-19442-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Mon, 16 Jan 2017 14:16:35 +0000

> This patchset records per-interface packet stats in the MPLS
> forwarding path and exports them using a nest of attributes root at a
> new IFLA_STATS_AF_SPEC attribute as part of RTM_GETSTATS messages:
> 
> [IFLA_STATS_AF_SPEC]
>  -> [AF_MPLS]
>   -> [MPLS_STATS_LINK]
>    -> struct mpls_link_stats
> 
> The first patch adds the rtnl infrastructure for this, including a new
> callbacks to per-AF ops of fill_stats_af and get_stats_af_size. The
> second patch records MPLS stats and makes use of the infrastructure to
> export them. The rtnl infrastructure could also be used to export IPv6
> stats in the future.
> 
> Changes in v2:
>  - make incrementing IPv6 stats in mpls_stats_inc_outucastpkts
>    conditional on CONFIG_IPV6 to fix build with CONFIG_IPV6=n

Series applied, thanks.
