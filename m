From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Mon, 17 Aug 2015 12:18:34 -0700 (PDT)
Message-ID: <20150817.121834.1051074493425670431.davem@davemloft.net>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbbHQTSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 15:18:35 -0400
In-Reply-To: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Fri, 14 Aug 2015 12:23:40 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> Currently, if phy state is PHY_RUNNING, we always register a CHANGE
> when phy works in polling or interrupt ignored, this will make the
> adjust_link being called even the phy link did Not changed.
> 
> checking the phy link to make sure the link did changed before we
> register a CHANGE, if link did not changed, we do nothing.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied, thank you.
