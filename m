From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] net: mvpp2: add TX interrupts support
Date: Thu, 03 Aug 2017 15:16:31 -0700 (PDT)
Message-ID: <20170803.151631.1327349080053900395.davem@davemloft.net>
References: <20170803084201.30305-1-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nadavh@marvell.com, hannah@marvell.com,
        yehuday@marvell.com, stefanc@marvell.com, mw@semihalf.com,
        antoine.tenart@free-electrons.com, jason@lakedaemon.net,
        andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        miquel.raynal@free-electrons.com,
        linux-arm-kernel@lists.infradead.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50178 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751924AbdHCWQc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:16:32 -0400
In-Reply-To: <20170803084201.30305-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Thu,  3 Aug 2017 10:41:54 +0200

> So far, the mvpp2 driver was using an hrtimer to handle TX
> completion. This patch series adds support for using TX interrupts
> (for each CPU) on PPv2.2, the variant of the IP used on Marvell Armada
> 7K/8K.
> 
> Dave: this version can be applied right away, it no longer depends on
> Antoine's patch series. Antoine series had some comments, so he will
> have to respin later on. Therefore, let's merge this smaller patch
> series first.
> 
> Changes since v1:
> 
>  - Rebased on top of net-next, instead of on top of Antoine's series.
> 
>  - Removed the Device Tree patch, as it shouldn't go through the net
>    tree.

Series applied.
