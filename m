From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Fix compile error when driver is comiled-in
Date: Fri, 16 Dec 2011 15:27:26 -0500 (EST)
Message-ID: <20111216.152726.1312007167282874878.davem@davemloft.net>
References: <20111215164837.GE2112@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sfr@canb.auug.org.au
To: joerg.roedel@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760558Ab1LPU3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:29:40 -0500
In-Reply-To: <20111215164837.GE2112@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joerg Roedel <joerg.roedel@amd.com>
Date: Thu, 15 Dec 2011 17:48:37 +0100

> Testing my iommu-configs against linux-next found a compile error for
> allyesconfig. It only happens when the mlx4 driver is compiled into the
> kernel and not as a module because these two static functions are also
> used in another file. The attached patch fixes it.
> 
>>From b993c4448c2ce5447fd24e7d4fce02e633d3222e Mon Sep 17 00:00:00 2001
> From: Joerg Roedel <joerg.roedel@amd.com>
> Date: Thu, 15 Dec 2011 17:30:33 +0100
> Subject: [PATCH 1/2] mlx4: Fix compile error when driver is comiled-in
> 
> This patch fixes a compile error that occurs when the driver
> is compile into the kernel and not as a module.
> 
> Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>

I wish we detected "exporting symbol marked static" properly.

I'll apply this, thanks!
