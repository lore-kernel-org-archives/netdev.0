From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] tg3: Fix advertisement handling
Date: Tue, 22 Nov 2011 15:18:06 -0500 (EST)
Message-ID: <20111122.151806.1120520761351993603.davem@davemloft.net>
References: <20111122230541.f2f96c9e.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146Ab1KVUSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 15:18:10 -0500
In-Reply-To: <20111122230541.f2f96c9e.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Tue, 22 Nov 2011 23:05:41 +0900

> Commit 28011cf19b (net: Add ethtool to mii advertisment conversion
> helpers) added a helper function ethtool_adv_to_mii_100bt() and
> tg3_copper_is_advertising_all(), tg3_phy_autoneg_cfg() were
> modified to use this.
> Before that commit, ethtool to mii advertisement conversion was
> done wrt speed, but now pause operation is also taken account.
> So, in tg3_copper_is_advertising_all(), below condition becomes
> true and this makes link up fails.
> 
> 	if ((adv_reg & ADVERTISE_ALL) != all_mask)
> 		return 0;
> 
> To fix this add ADVERTISE_ALL bit and operation to cap speed,
> and change default advertisement not including ADVERTISED_Pause.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> ---
> V2: change default advertisement not including ADVERTISED_Pause

I'll apply this, thank you.
