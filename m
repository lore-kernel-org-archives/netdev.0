From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: set skb->hash type properly
Date: Wed, 02 Nov 2016 15:33:11 -0400 (EDT)
Message-ID: <20161102.153311.601230263396468572.davem@davemloft.net>
References: <20161102005850.9904-1-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, netdev@vger.kernel.org, _govind@gmx.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45746 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbcKBTdN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 15:33:13 -0400
In-Reply-To: <20161102005850.9904-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Tue,  1 Nov 2016 17:58:50 -0700

> From: Govindarajulu Varadarajan <_govind@gmx.com>
> 
> Driver sets the skb l4/l3 hash based on NIC_CFG_RSS_HASH_TYPE_*,
> which is bit mask. This is wrong. Hw actually provides us enum.
> Use CQ_ENET_RQ_DESC_RSS_TYPE_* to set l3 and l4 hash type.
> 
> Fixes: bf751ba802fe ("driver/net: enic: record q_number and rss_hash for skb")
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, thanks.
