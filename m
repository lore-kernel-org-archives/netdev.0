From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] cxgb4: add support to offload tc flower
Date: Fri, 22 Sep 2017 21:28:24 -0700 (PDT)
Message-ID: <20170922.212824.644618990399880097.davem@davemloft.net>
References: <cover.1506015856.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: rahul.lakkireddy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdIWE2Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 00:28:25 -0400
In-Reply-To: <cover.1506015856.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Date: Thu, 21 Sep 2017 23:41:12 +0530

> This series of patches add support to offload tc flower onto Chelsio
> NICs.
> 
> Patch 1 adds basic skeleton to prepare for offloading tc flower flows.
> 
> Patch 2 adds support to add/remove flows for offload.  Flows can have
> accompanying masks.  Following match and action are currently supported
> for offload:
> Match:  ether-protocol, IPv4/IPv6 addresses, L4 ports (TCP/UDP)
> Action: drop, redirect to another port on the device.
> 
> Patch 3 adds support to offload tc-flower flows having
> vlan actions: pop, push, and modify.
> 
> Patch 4 adds support to fetch stats for the offloaded tc flower flows
> from hardware.
> 
> Support for offloading more match and action types are to be followed
> in subsequent series.

Series applied, thank you.
