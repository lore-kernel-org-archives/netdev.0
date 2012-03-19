From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1] mlx4_core: fix race on comm channel
Date: Mon, 19 Mar 2012 18:06:37 -0400 (EDT)
Message-ID: <20120319.180637.1743774761681322216.davem@davemloft.net>
References: <4F65F1E8.9000505@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757108Ab2CSWGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 18:06:46 -0400
In-Reply-To: <4F65F1E8.9000505@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 18 Mar 2012 16:32:08 +0200

> From: Eugenia Emantayev <eugenia@mellanox.co.il>
> 
> 
> Prevent race condition between commands on comm channel.
> Happened while unloading the driver when switching from
> event to polling mode. VF got completion on the last command
> before switching to polling mode, but toggle was not changed.
> After the fix - VF will not write the next command before
> toggle is updated.
> 
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>

Applied.
