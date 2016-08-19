From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/5] net_sched, flow_dissector, flower:
 Introduce vlan tag support
Date: Thu, 18 Aug 2016 23:14:14 -0700 (PDT)
Message-ID: <20160818.231414.1576833647538773356.davem@davemloft.net>
References: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, amirva@mellanox.com,
        ogerlitz@mellanox.com, tom@herbertland.com
To: hadarh@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42339 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbcHSGOP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:14:15 -0400
In-Reply-To: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>
Date: Wed, 17 Aug 2016 13:36:09 +0300

> This patchset introduce vlan tag support to the flower classifier and the flow
> dissector. In addition to adding vlan priority to act vlan.
> 
> The first 2 patches are dealing with flow-dissector:
>  - The first patch is a fix, in case the vlan was already stripped from the
>    skb, take it from skb->vlan_tci.
>  - The second patch adds support for vlan priority.
> 
> The next 2 patches are dealing with flower:
>  - The first patch is a fix, sets flow dissector 'used_keys' according to the
>    mask value of each key.
>  - The secound patch adds vlan tag support to the flower classifier, user space
>    patches will be sent later to complete it.
> 
> The last patch adds vlan priority to act vlan since only vlan id is currently supported.
> 
> Changes from V1:
>  - A new patch was added to this series "net_sched: flower: Avoid dissection of unmasked keys"
>  - Adding u16 padding to struct flow_dissector_key_vlan
>  - change flow_label field in struct flow_dissector_key_tags form 20 bits field to u32
>  - Remove 'if (v->tcfv_push_prio)' check from tcf_vlan_dump function
>  - Add support to un-stripped vlan skb and skb with multipale vlans in __skb_flow_dissect

Series applied, thanks.
