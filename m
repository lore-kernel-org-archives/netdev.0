From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v11 1/1] net: phy: Cleanup the Edge-Rate
 feature in Microsemi PHYs.
Date: Fri, 14 Oct 2016 11:05:44 -0400 (EDT)
Message-ID: <20161014.110544.269842399219820528.davem@davemloft.net>
References: <20161013.100141.1588302672560551253.davem@davemloft.net>
        <1476382890-7275-1-git-send-email-allan.nielsen@microsemi.com>
        <1476382890-7275-2-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com
To: allan.nielsen@microsemi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752057AbcJNPFq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 11:05:46 -0400
In-Reply-To: <1476382890-7275-2-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Date: Thu, 13 Oct 2016 20:21:30 +0200

> Edge-Rate cleanup include the following:
> - Updated device tree bindings documentation for edge-rate
> - The edge-rate is now specified as a "slowdown", meaning that it is now
>   being specified as positive values instead of negative (both
>   documentation and implementation wise).
> - Only explicitly documented values for "vsc8531,vddmac" and
>   "vsc8531,edge-slowdown" are accepted by the device driver.
> - Deleted include/dt-bindings/net/mscc-phy-vsc8531.h as it was not needed.
> - Read/validate devicetree settings in probe instead of init
> 
> Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
> Signed-off-by: Raju Lakkaraju <raju.lakkaraju@microsemi.com>

This patch does not apply to the net-next tree.

Take my tree, put this email of your's into a file, and run this:

bash$ git am file

and you will get:

[davem@dhcp-10-15-49-210 net-next]$ git am --signoff net-next-v11-1-1-net-phy-Cleanup-the-Edge-Rate-feature-in-Microsemi-PHYs..patch 
Applying: net: phy: Cleanup the Edge-Rate feature in Microsemi PHYs.
error: patch failed: Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt:6
error: Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt: patch does not apply
error: patch failed: drivers/net/phy/mscc.c:12
error: drivers/net/phy/mscc.c: patch does not apply
error: include/dt-bindings/net/mscc-phy-vsc8531.h: does not exist in index
Patch failed at 0001 net: phy: Cleanup the Edge-Rate feature in Microsemi PHYs.
The copy of the patch that failed is found in:
   /home/davem/src/GIT/net-next/.git/rebase-apply/patch
When you have resolved this problem, run "git am --continue".
If you prefer to skip this patch, run "git am --skip" instead.
To restore the original branch and stop patching, run "git am --abort".

Please do not resubmit this patch until you can successfully email the
patch to yourself and apply it cleanly to the net-next tree.
