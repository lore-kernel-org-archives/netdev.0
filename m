From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] r8169: Be drop monitor friendly
Date: Fri, 25 Aug 2017 19:13:52 -0700 (PDT)
Message-ID: <20170825.191352.1130944822769604145.davem@davemloft.net>
References: <20170825013359.27258-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com, romieu@fr.zoreil.com,
        edumazet@gmail.com, alexander.h.duyck@intel.com,
        sgruszka@redhat.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751589AbdHZCN4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 22:13:56 -0400
In-Reply-To: <20170825013359.27258-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 24 Aug 2017 18:33:57 -0700

> First patch may be questionable but no other driver appears to be doing that
> and while it is defendable to account for left packets as dropped during TX
> clean, this appears misleadning. I picked Stanislaw changes which brings us
> back to 2010, but this was present from pre-git days as well.

Right, drivers should not do this.

> Second patch fixes the two missing calls to dev_consume_skb_any().

Series applied, thanks.
