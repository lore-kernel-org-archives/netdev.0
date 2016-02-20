From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fmvj18x_cs: The MAC address of FMV-J182 is stored at
 buf[5]
Date: Fri, 19 Feb 2016 22:10:14 -0500 (EST)
Message-ID: <20160219.221014.2230058563470668402.davem@davemloft.net>
References: <20160220105706.c4da2bbf13902b8bb4df3808@nifty.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@nifty.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1427595AbcBTDKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 22:10:18 -0500
In-Reply-To: <20160220105706.c4da2bbf13902b8bb4df3808@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@nifty.com>
Date: Sat, 20 Feb 2016 10:57:06 +0900

> 
> The MAC address of FMV-J182 is stored at buf[5].
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@nifty.com>

This is an extremely poor and misleading description of your change.

The original code was accessing the MAC address properly at buf[5] by
starting the iterator 'i' at 5.

The bug is that the indexing of dev->dev_addr[] is incorrect.

Please describe your change more accurately and resubmit this patch.

Thanks.
