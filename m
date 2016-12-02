From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/8] Offloading tc rules using underline
 Hardware device
Date: Fri, 02 Dec 2016 13:29:45 -0500 (EST)
Message-ID: <20161202.132945.1367454131310851397.davem@davemloft.net>
References: <1480594000-8428-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saeedm@mellanox.com, jiri@mellanox.com,
        amirva@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com
To: hadarh@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753936AbcLBSaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:30:04 -0500
In-Reply-To: <1480594000-8428-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>
Date: Thu,  1 Dec 2016 14:06:32 +0200

> This series adds flower classifier support in offloading tc rules when the
> Software ingress device is different from the Hardware ingress device, 
> such as when dealing with IP tunnels  
> 
> The first two patches are a small fixes to flower, checking the skip_hw flag
> wasn't set before calling the Hardware offloading functions which will try to
> offload the rule.
> 
> The next two patches are infrastructure patches, a preparation for the fourth
> patch which is adding support in flower to offload rules when the ingress
> device is not a Hardware device and therefore can't offload.
> In this case ndo_setup_tc is called with the mirred (egress) device.
> 
> The last three patchs are adding mlx5e support to offload rules using the new
> "egress_device" flag.
 ...
> Changes from v0:
> - check if CONFIG_NET_CLS_ACT is defined befor calling tc_action_ops get_dev()

Series applied, thanks.
