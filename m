From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: destroy workqueue when driver fails to
 register
Date: Tue, 03 Dec 2013 11:56:04 -0500 (EST)
Message-ID: <20131203.115604.955668068029147691.davem@davemloft.net>
References: <1386036250-8485-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, jackm@dev.mellanox.co.il,
	netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412Ab3LCQ4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 11:56:06 -0500
In-Reply-To: <1386036250-8485-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Tue,  3 Dec 2013 10:04:10 +0800

> When driver registration fails, we need to clean up the resources allocated
> before. mlx4_core missed destroying the workqueue allocated.
> 
> This patch destroys the workqueue when registration fails.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

Applied.
