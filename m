From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] dwc_eth_qos: do not clear pause flags from
 phy_device->supported
Date: Tue, 18 Oct 2016 10:29:35 -0400 (EDT)
Message-ID: <20161018.102935.2077853149914307916.davem@davemloft.net>
References: <1476775233-14633-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: larper@axis.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, niklass@axis.com, jespern@axis.com
To: niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42178 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933782AbcJRO3i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 10:29:38 -0400
In-Reply-To: <1476775233-14633-1-git-send-email-niklass@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Tue, 18 Oct 2016 09:20:33 +0200

> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> phy_device->supported is originally set by the PHY driver.
> The ethernet driver should filter phy_device->supported to only contain
> flags supported by the IP.
> The IP supports setting rx and tx flow control independently,
> therefore SUPPORTED_Pause and SUPPORTED_Asym_Pause should not be cleared.
> If the flags are cleared, pause frames cannot be enabled (even if they
> are supported by the PHY).
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> Signed-off-by: Jesper Nilsson <jespern@axis.com>
> Acked-by: Lars Persson <larper@axis.com>

Applied.
