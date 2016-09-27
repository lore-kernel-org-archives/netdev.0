From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: ethernet: mediatek: some bug fixes
 for PDAM and HW LRO
Date: Tue, 27 Sep 2016 09:42:24 -0400 (EDT)
Message-ID: <20160927.094224.1540701192272023517.davem@davemloft.net>
References: <1474871630-4134-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, nelsonch.tw@gmail.com
To: nelson.chang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47440 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752768AbcI0Nmb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 09:42:31 -0400
In-Reply-To: <1474871630-4134-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson Chang <nelson.chang@mediatek.com>
Date: Mon, 26 Sep 2016 14:33:48 +0800

> 1) Add to stop PDMA while stopping the frame engine
> 2) Modify the register settings for LRO relinquishments
> 3) Jump out from the waiting loop while LRO relinquishments are done

Series applied, but like Sergei I think you should have split patch
#2 into two separate patches.

You even list the changes individually here in your header
posting.
