From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/flower: Fix pointer cast
Date: Fri, 11 Mar 2016 12:04:56 -0500 (EST)
Message-ID: <20160311.120456.1412463922322950179.davem@davemloft.net>
References: <1457687325-11214-1-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932596AbcCKRE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 12:04:59 -0500
In-Reply-To: <1457687325-11214-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>
Date: Fri, 11 Mar 2016 11:08:45 +0200

> Cast pointer to unsigned long instead of u64, to fix compilation warning
> on 32 bit arch, spotted by 0day build.
> 
> Fixes: 5b33f48 ("net/flower: Introduce hardware offload support")
> Signed-off-by: Amir Vadai <amir@vadai.me>

Applied, thanks.
