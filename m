From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1] net/mlx4: Set proper build dependancy with vxlan
Date: Tue, 01 Apr 2014 16:27:06 -0400 (EDT)
Message-ID: <20140401.162706.668882765857088076.davem@davemloft.net>
References: <1396340833-17125-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbaDAU1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:27:08 -0400
In-Reply-To: <1396340833-17125-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue,  1 Apr 2014 11:27:13 +0300

> Make sure that vxlan_get_rx_port() is present in the kernel build in a manner
> consistent with mlx4, else mlx4 can be made built-in where vxlan a module and
> the phase of the build linking fails. Add CONFIG_MLX4_EN_VXLAN for that.
> 
> Also, #ifdef the advertizement and implementation of the mlx4 vxlan ndo
> calls and related code under this config directive.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied.
