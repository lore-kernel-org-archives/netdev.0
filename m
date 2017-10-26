From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] net: mvpp2: fix invalid parameters order when
 calling the tcam init
Date: Thu, 26 Oct 2017 17:08:24 +0900 (KST)
Message-ID: <20171026.170824.1953204734839892847.davem@davemloft.net>
References: <20171024094128.24433-1-antoine.tenart@free-electrons.com>
        <20171024094128.24433-2-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751162AbdJZII3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:08:29 -0400
In-Reply-To: <20171024094128.24433-2-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Tue, 24 Oct 2017 11:41:27 +0200

> When calling mvpp2_prs_mac_multi_set() from mvpp2_prs_mac_init(), two
> parameters (the port index and the table index) are inverted. Fixes
> this.
> 
> Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375 network unit")
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Applied.
