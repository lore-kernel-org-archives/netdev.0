From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: rescan if key is lost during dump
Date: Thu, 31 Jan 2008 16:45:59 -0800 (PST)
Message-ID: <20080131.164559.178846710.davem@davemloft.net>
References: <479833EE.1090905@linux-foundation.org>
	<20080123.232747.75654058.davem@davemloft.net>
	<20080124135112.32b5c1c7@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40850
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759409AbYBAAph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 19:45:37 -0500
In-Reply-To: <20080124135112.32b5c1c7@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 24 Jan 2008 13:51:12 -0800

> Normally during a dump the key of the last dumped entry is used for
> continuation, but since lock is dropped it might be lost. In that case
> fallback to the old counter based N^2 behaviour.  This means the dump will end up
> skipping some routes which matches what FIB_HASH does.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
