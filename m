From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_core: Remove unnecessary validation
 for port number
Date: Tue, 21 Jan 2014 23:14:48 -0800 (PST)
Message-ID: <20140121.231448.93291561692199367.davem@davemloft.net>
References: <1390292377-11806-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	monis@mellanox.co.il, matanb@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbaAVHOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 02:14:48 -0500
In-Reply-To: <1390292377-11806-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 21 Jan 2014 10:19:37 +0200

> From: Moni Shoua <monis@mellanox.co.il>
> 
> This is a fix to a regression introduced by commit:
> "982290a net/mlx4_core: Check port number for validity
> before accessing data"
> 
> IPoIB could not attach to multicast group and we get this in dmesg:
> [144214.145008] ib0: failed to attach to multicast group, ret = -22
> [144214.145016] ib0: couldn't attach QP to multicast group ff12:401b:ffff:0000:0000:0000:ffff:ffff
> [144214.145019] ib0: multicast join failed for ff12:401b:ffff:0000:0000:0000:ffff:ffff, status -22
> 
> The cause to the problem is because port is extracted from gid[5].
> Which is only valid for Ethernet.
> Removed this validation in mlx4_qp_attach_common(), which is accessed
> from both Ethernet and IB flows.
> Error flow for bad port value in Ethernet is already exists in that
> function.
> 
> Signed-off-by: Moni Shoua <monis@mellanox.co.il>
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thank you.
