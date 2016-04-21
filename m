From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 9/9] net/mlx5e: Reset link modes upon setting speed
 to zero
Date: Thu, 21 Apr 2016 14:04:54 -0400 (EDT)
Message-ID: <20160421.140454.143155848960923980.davem@davemloft.net>
References: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
	<1461069222-27076-10-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	eranbe@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbcDUSE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:04:56 -0400
In-Reply-To: <1461069222-27076-10-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue, 19 Apr 2016 15:33:42 +0300

> Upon ethtool request to set speed to 0 we handle it as a special request
> to reset link modes to Device's defaults.
> 
> Fixes: f62b8bb8f2d3 ("net/mlx5: Extend mlx5_core to support ConnectX-4
> Ethernet functionality")
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Please don't try to sneak things like this into the patches you submit.

If you continue to add weird stuff like this, I will never _ever_ be
able to trust you guys and have a high degree of confidence in your
changes.  If you continue like this, I will always have to audit your
patches very strictly which is very time consuming for me.

Do not extend ethtool's semantics in a way which suits you specifically.

If we want to have this semantic, you must first propose it as a
global semantic which then in turn can be adopted by all drivers
supporting ethtool.

Thank you.
