From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mvpp2: fix the packet size configuration
 for 10G
Date: Fri, 25 Aug 2017 20:11:19 -0700 (PDT)
Message-ID: <20170825.201119.1589324299312300137.davem@davemloft.net>
References: <20170825132446.1130-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751901AbdHZDLU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 23:11:20 -0400
In-Reply-To: <20170825132446.1130-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Fri, 25 Aug 2017 15:24:46 +0200

> The MVPP22_XLG_CTRL1_FRAMESIZELIMIT define is used as an offset, but is
> defined as BIT(0). Updated its name to contains "OFFS" as in offset and
> fix its value using the offset value, 0.
> 
> Reported-by: Stefan Chulski <stefanc@marvell.com>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Fixes: 76eb1b1de5b6 ("net: mvpp2: set maximum packet size for 10G ports")

Applied, thanks.
