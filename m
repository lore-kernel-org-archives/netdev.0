From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] rds: rds-stress show all zeros after few minutes
Date: Thu, 31 Mar 2016 16:02:46 -0400 (EDT)
Message-ID: <20160331.160246.2179579552166806534.davem@davemloft.net>
References: <1459405762-29778-1-git-send-email-shamir.rabinovitch@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: shamir.rabinovitch@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbcCaUCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 16:02:47 -0400
In-Reply-To: <1459405762-29778-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: shamir rabinovitch <shamir.rabinovitch@oracle.com>
Date: Thu, 31 Mar 2016 02:29:22 -0400

> Issue can be seen on platforms that use 8K and above page size
> while rds fragment size is 4K. On those platforms single page is
> shared between 2 or more rds fragments. Each fragment has its own
> offset and rds congestion map code need to take this offset to account.
> Not taking this offset to account lead to reading the data fragment
> as congestion map fragment and hang of the rds transmit due to far
> congestion map corruption.
> 
> Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>
> 
> Reviewed-by: Wengang Wang <wen.gang.wang@oracle.com>
> Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Tested-by: Anand Bibhuti <anand.bibhuti@oracle.com>

This doesn't apply cleanly to my current tree, please respin.
