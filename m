From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gianfar: add ethtool eee support
Date: Thu, 08 Dec 2016 18:19:22 -0500 (EST)
Message-ID: <20161208.181922.957507188752351548.davem@davemloft.net>
References: <1481196426-45576-1-git-send-email-Shaohui.Xie@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shaohui.Xie@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45294 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753170AbcLHXTq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 18:19:46 -0500
In-Reply-To: <1481196426-45576-1-git-send-email-Shaohui.Xie@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@nxp.com>
Date: Thu, 8 Dec 2016 19:27:06 +0800

> Gianfar does not support EEE, but it can connect to a PHY which supports
> EEE and the PHY advertises EEE by default, and its link partner also
> advertises EEE, so the PHY enters low power mode when traffic rate is low,
> which causes packet loss if an application's traffic rate is low. This
> patch provides .get_eee and .set_eee so that to disable the EEE
> advertisement via ethtool if needed, other EEE features are not supported.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@nxp.com>

This is not the way to fix this.

If the Gianfar MAC does not support EEE properly, then the gianfar
driver should not create a situation where the PHY advertises EEE
in the first place.
