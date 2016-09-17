From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: ethernet: mediatek: add HW LRO
 functions
Date: Sat, 17 Sep 2016 09:46:26 -0400 (EDT)
Message-ID: <20160917.094626.1566729007953672684.davem@davemloft.net>
References: <1473832739-4983-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, f.fainelli@gmail.com, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        nelsonch.tw@gmail.com
To: nelson.chang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59966 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751134AbcIQNqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 09:46:30 -0400
In-Reply-To: <1473832739-4983-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson Chang <nelson.chang@mediatek.com>
Date: Wed, 14 Sep 2016 13:58:56 +0800

> The series add the large receive offload (LRO) functions by hardware and
> the ethtool functions to configure RX flows of HW LRO.
> 
> changes since v2:
> - Add ndo_fix_features to prevent NETIF_F_LRO off while RX flow is programmed
> - Rephrase the dts property is a capability if the hardware supports LRO
> 
> changes since v1:
> - Add HW LRO support
> - Add ethtool hooks to set LRO RX flows

This doesn't apply cleanly to net-next.
