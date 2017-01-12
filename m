From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v2] net: qcom/emac: grab a reference to the phydev on
 ACPI systems
Date: Thu, 12 Jan 2017 15:14:23 -0500 (EST)
Message-ID: <20170112.151423.1152252804419911864.davem@davemloft.net>
References: <1484174751-19036-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johan@kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56350 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdALUOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:14:30 -0500
In-Reply-To: <1484174751-19036-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Wed, 11 Jan 2017 16:45:51 -0600

> Commit 6ffe1c4cd0a7 ("net: qcom/emac: fix of_node and phydev leaks")
> fixed the problem with reference leaks on phydev, but the fix is
> device-tree specific.  When the driver unloads, the reference is
> dropped only on DT systems.
> 
> Instead, it's cleaner if up grab an reference on ACPI systems.
> When the driver unloads, we can drop the reference without having
> to check whether we're on a DT system.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied.
