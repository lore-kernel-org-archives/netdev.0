From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: mediatek: use
 [get|set]_link_ksettings
Date: Thu, 22 Sep 2016 08:23:22 -0400 (EDT)
Message-ID: <20160922.082322.1182869004925614678.davem@davemloft.net>
References: <1474533723-22629-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com, objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60132 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751586AbcIVMX0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 08:23:26 -0400
In-Reply-To: <1474533723-22629-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sean.wang@mediatek.com>
Date: Thu, 22 Sep 2016 16:42:03 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> 1) use new api [get|set]_link_ksettings instead
> of [get|set]_settings old ones.
> 
> 2) dev->phydev is sure being ready before calling
> these callbacks, so removing all the sanity check
> if it is existing.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Applied.
