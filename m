From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/2] net/sched: cls_flower: Add support for
 matching on dissection flags
Date: Thu, 08 Dec 2016 11:33:10 -0500 (EST)
Message-ID: <20161208.113310.2200395041008288200.davem@davemloft.net>
References: <1481112191-14115-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, roid@mellanox.com,
        hadarh@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753962AbcLHQdM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 11:33:12 -0500
In-Reply-To: <1481112191-14115-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed,  7 Dec 2016 14:03:09 +0200

> This series add the UAPI to provide set of flags for matching, where the 
> flags provided from user-space are mapped to flow-dissector flags.
> 
> The 1st flag allows to match on whether the packet is an
> IP fragment and corresponds to the FLOW_DIS_IS_FRAGMENT flag.
  ...
> v2->v3:
>   - replace BIT() with << (kbuild test robot)
> 
> v1->v2:
>  - dropped the flow dissector patch (#1) as no changes are needed there (Jiri)
>  - applied code review comments from Jiri to the flower patch

Series applied.
