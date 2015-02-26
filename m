From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bcmgenet: fix throughtput regression with TSO
 autosizing
Date: Thu, 26 Feb 2015 11:36:50 -0500 (EST)
Message-ID: <20150226.113650.2092516427472228316.davem@davemloft.net>
References: <1424948758-48244-1-git-send-email-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: jaedon.shin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbbBZQgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:36:52 -0500
In-Reply-To: <1424948758-48244-1-git-send-email-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaedon Shin <jaedon.shin@gmail.com>
Date: Thu, 26 Feb 2015 20:05:58 +0900

> This patch prevents the performance degradation of xmit after
> 605ad7f ("tcp: refine TSO autosizing").
> 
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>

I doubt this is the correct way to fix this.

Also, you need to describe in detail what the actual problem
is, how you evaluated the cause, and what made you think that
your choosen solution is the proper one.
