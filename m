From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow sleeping when modifying store_rps_map
Date: Thu, 13 Aug 2015 21:41:07 -0700 (PDT)
Message-ID: <20150813.214107.830938216718961195.davem@davemloft.net>
References: <1439488996-31227-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbbHNE4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 00:56:18 -0400
In-Reply-To: <1439488996-31227-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <sasha.levin@oracle.com>
Date: Thu, 13 Aug 2015 14:03:16 -0400

> Commit 10e4ea751 ("net: Fix race condition in store_rps_map") has moved the
> manipulation of the rps_needed jump label under a spinlock. Since changing
> the state of a jump label may sleep this is incorrect and causes warnings
> during runtime.
> 
> Make rps_map_lock a mutex to allow sleeping under it.
> 
> Fixes: 10e4ea751 ("net: Fix race condition in store_rps_map")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.
