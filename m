From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Fri, 15 Sep 2017 16:14:03 -0700 (PDT)
Message-ID: <20170915.161403.2131524326226213839.davem@davemloft.net>
References: <20170915222218.6613-1-rosenp@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, nbd@nbd.name
To: rosenp@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdIOXOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 19:14:09 -0400
In-Reply-To: <20170915222218.6613-1-rosenp@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rosen Penev <rosenp@gmail.com>
Date: Fri, 15 Sep 2017 15:22:18 -0700

> On a linksys E1200v1 (actually a crossflashed E1000v2), the offloading features give no measurable benefit to speed or latency. Furthermore, disabling GRO actually improves iperf performance by a whoppimg 3mbps. Results:
 ...
> -	net_dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> +	net_dev->features &= NETIF_F_GRO;
>  	net_dev->hw_features = net_dev->features;

This doesn't disable GRO.
