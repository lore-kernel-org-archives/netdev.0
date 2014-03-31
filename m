From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4: Set proper build dependancy with
 vxlan
Date: Mon, 31 Mar 2014 16:29:14 -0400 (EDT)
Message-ID: <20140331.162914.820542941540073428.davem@davemloft.net>
References: <1396178905-3817-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbaCaU3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:29:16 -0400
In-Reply-To: <1396178905-3817-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 30 Mar 2014 14:28:25 +0300

> Make sure that vxlan_get_rx_port() is present in the kernel build in a manner
> consistent with mlx4. Otherwise, mlx4 can be made built-in where vxlan as a module
> and the linking phase of the kernel build fails. Add CONFIG_MLX4_EN_VXLAN for that.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Please do this properly like the I40E_VXLAN Kconfig knob does, you have
to protect everything including the ndo_*() methods and support code.
