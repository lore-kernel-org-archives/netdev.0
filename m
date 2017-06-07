From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: mvpp2: do not bypass the mvpp22_port_mii_set
 function
Date: Wed, 07 Jun 2017 15:08:36 -0400 (EDT)
Message-ID: <20170607.150836.1506071311612042001.davem@davemloft.net>
References: <20170607061750.28516-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751684AbdFGTIj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:08:39 -0400
In-Reply-To: <20170607061750.28516-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Wed,  7 Jun 2017 08:17:50 +0200

> The mvpp22_port_mii_set() function was added by 2697582144dd, but the
> function directly returns without doing anything. This return was used
> when debugging and wasn't removed before sending the patch. Fix this.
> 
> Fixes: 2697582144dd ("net: mvpp2: handle misc PPv2.1/PPv2.2 differences")
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Applied, thank you.
