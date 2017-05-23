From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 netdev] net: phy: marvell: Limit errata to 88m1101
Date: Tue, 23 May 2017 11:19:17 -0400 (EDT)
Message-ID: <20170523.111917.1861537319570026837.davem@davemloft.net>
References: <1495495713-28374-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: danielwa@cisco.com, harini.katakam@xilinx.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36198 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933289AbdEWPTV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:19:21 -0400
In-Reply-To: <1495495713-28374-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 23 May 2017 01:28:33 +0200

> The 88m1101 has an errata when configuring autoneg. However, it was
> being applied to many other Marvell PHYs as well. Limit its scope to
> just the 88m1101.
> 
> Fixes: 76884679c644 ("phylib: Add support for Marvell 88e1111S and 88e1145")
> Reported-by: Daniel Walker <danielwa@cisco.com>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

This patch is targetting 'net' but you generated it against 'net-next'
which had a comment formatting change made recently so this patch won't
apply to 'net'.

Please respin against 'net'.

Thanks.
