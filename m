From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ibm: emac: fix regression caused by
 emac_dt_phy_probe()
Date: Wed, 08 Mar 2017 22:18:28 -0800 (PST)
Message-ID: <20170308.221828.111180540611215509.davem@davemloft.net>
References: <20170306133427.27025-1-chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, runaway@candw.ms
To: chunkeey@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751013AbdCIGZJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 01:25:09 -0500
In-Reply-To: <20170306133427.27025-1-chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Lamparter <chunkeey@googlemail.com>
Date: Mon,  6 Mar 2017 14:34:27 +0100

> Julian Margetson reported a panic on his SAM460EX with Kernel 4.11-rc1:
 ...
> The problem is caused by emac_dt_phy_probe() returing success (0)
> for existing device-trees configurations that do not specify a
> "phy-handle" property. This caused the code to skip the existing
> phy probe and setup. Which led to essential phy related
> data-structures being uninitialized.
> 
> This patch also removes the unused variable in emac_dt_phy_connect().
> 
> Fixes: a577ca6badb5261d ("net: emac: add support for device-tree based PHY discovery and setup")
> Reported-by: Julian Margetson <runaway@candw.ms>
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>

Applied, thanks.
