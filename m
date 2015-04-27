From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1] net/mlx4_en: Prevent setting invalid RSS hash
 function
Date: Mon, 27 Apr 2015 13:38:06 -0400 (EDT)
Message-ID: <20150427.133806.630452833895648311.davem@davemloft.net>
References: <1430131256-9561-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	ben@decadent.org.uk
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbbD0RiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:38:09 -0400
In-Reply-To: <1430131256-9561-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 27 Apr 2015 13:40:56 +0300

> mlx4_en_check_rxfh_func() was checking for hardware support before
> setting a known RSS hash function, but didn't do any check before
> setting unknown RSS hash function. Need to make it fail on such values.
> In this occasion, moved the actual setting of the new value from the
> check function into mlx4_en_set_rxfh().
> 
> Fixes: 947cbb0 ("net/mlx4_en: Support for configurable RSS hash function")
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied and queued up for -stable, thanks.
