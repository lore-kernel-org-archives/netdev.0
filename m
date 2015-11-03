From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v3] net: phy: fix a bug in get_phy_c45_ids
Date: Mon, 02 Nov 2015 23:45:57 -0500 (EST)
Message-ID: <20151102.234557.2138288424124774759.davem@davemloft.net>
References: <1446524853-3050-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687AbbKCEp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 23:45:58 -0500
In-Reply-To: <1446524853-3050-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Tue, 3 Nov 2015 12:27:33 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> When probing devices-in-package for a c45 phy, device zero is the last
> device to probe, however, if driver reads 0 from device zero,
> c45_ids->devices_in_package is set to '0', the loop condition of probing
> will be matched again, see codes below:
> 
> for (i = 1;i < num_ids && c45_ids->devices_in_package == 0;i++)
> 
> driver will run in a dead loop.
> 
> This patch restructures the bug and confusing loop, it provides a helper
> function get_phy_c45_devs_in_pkg which to read devices-in-package registers
> of a MMD, and rewrites the loop with using the helper function.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied.
