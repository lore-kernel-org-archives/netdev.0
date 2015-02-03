From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Fix kernel Oops (mem corruption)
 when working with more than 80 VFs
Date: Mon, 02 Feb 2015 19:38:16 -0800 (PST)
Message-ID: <20150202.193816.1901787169522382523.davem@davemloft.net>
References: <1422883122-29020-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, jackm@dev.mellanox.co.il
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932825AbbBCDiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:38:17 -0500
In-Reply-To: <1422883122-29020-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon,  2 Feb 2015 15:18:42 +0200

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> 
> Commit de966c592802 (net/mlx4_core: Support more than 64 VFs) was meant to
> allow up to 126 VFs.  However, due to leaving MLX4_MFUNC_MAX too low, using
> more than 80 VFs resulted in memory corruptions (and Oopses) when more than
> 80 VFs were requested. In addition, the number of slaves was left too high.
> 
> This commit fixes these issues.
> 
> Fixes: de966c592802 ("net/mlx4_core: Support more than 64 VFs")
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
