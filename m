From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre6: allow to update all parameters via rtnl
Date: Fri, 04 Dec 2015 16:57:02 -0500 (EST)
Message-ID: <20151204.165702.1714745625413079332.davem@davemloft.net>
References: <1449159710-489-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867AbbLDV5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 16:57:04 -0500
In-Reply-To: <1449159710-489-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  3 Dec 2015 17:21:50 +0100

> Parameters were updated only if the kernel was unable to find the tunnel
> with the new parameters, ie only if core pamareters were updated (keys,
> addr, link, type).
> Now it's possible to update ttl, hoplimit, flowinfo and flags.
> 
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks.
