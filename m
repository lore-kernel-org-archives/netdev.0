From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] flow_dissector: Check skb for VLAN only if skb
 specified.
Date: Wed, 19 Oct 2016 10:36:07 -0400 (EDT)
Message-ID: <20161019.103607.842949345730109568.davem@davemloft.net>
References: <1476736212-21238-1-git-send-email-e@erig.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadarh@mellanox.com
To: e@erig.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942123AbcJSOgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:36:49 -0400
In-Reply-To: <1476736212-21238-1-git-send-email-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Garver <e@erig.me>
Date: Mon, 17 Oct 2016 16:30:12 -0400

> Fixes a panic when calling eth_get_headlen(). Noticed on i40e driver.
> 
> Fixes: d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci")
> Signed-off-by: Eric Garver <e@erig.me>

Applied, thanks.
