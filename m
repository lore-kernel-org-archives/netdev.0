From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] tipc: potential shift wrapping bug in map_set()
Date: Fri, 17 Jun 2016 21:27:19 -0700 (PDT)
Message-ID: <20160617.212719.1901762351352671976.davem@davemloft.net>
References: <20160617092226.GD25609@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbcFRE1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 00:27:20 -0400
In-Reply-To: <20160617092226.GD25609@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 17 Jun 2016 12:22:26 +0300

> "up_map" is a u64 type but we're not using the high 32 bits.
> 
> Fixes: 35c55c9877f8 ('tipc: add neighbor monitoring framework')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
