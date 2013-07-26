From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] gianfar: Fix data structure field
 comments in gianfar.h
Date: Fri, 26 Jul 2013 15:22:57 -0700 (PDT)
Message-ID: <20130726.152257.1002325488353326528.davem@davemloft.net>
References: <1374677015-23127-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809Ab3GZWW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 18:22:59 -0400
In-Reply-To: <1374677015-23127-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 24 Jul 2013 17:43:34 +0300

> Improve clarity of struct member comments for tx_q and and rx_q
> (see cur_tx, dirty_tx, skb_curtx). Fix misleading comments (see
> skb_currx, cur_rx) and remove outdated ones (txcount, txtime).
> Make comments readable (and maintainable) by placing them above
> the individual targeted members.
> Fix checkpatch warnings (see __aligned()) and spacing issues
> in the process.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Please don't undo the usage of kerneldoc comments to describe
structure members.

I'm not applying this patch series, sorry.
