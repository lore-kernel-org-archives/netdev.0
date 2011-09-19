From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix validation of D-SACK
Date: Sun, 18 Sep 2011 22:37:44 -0400 (EDT)
Message-ID: <20110918.223744.2195272571175354579.davem@davemloft.net>
References: <1316374544.31335.16.camel@edumazet-laptop>
	<20110918.210725.2061666096968958448.davem@davemloft.net>
	<4E76A36B.4060109@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab1ISChu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 22:37:50 -0400
In-Reply-To: <4E76A36B.4060109@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Mon, 19 Sep 2011 10:05:31 +0800

> D-SACK is allowed to reside below snd_una. But the corresponding check
> in tcp_is_sackblock_valid() is the exact opposite. It looks like a typo.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
