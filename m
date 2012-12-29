From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: make __kmalloc_reserve static
Date: Fri, 28 Dec 2012 20:33:15 -0800 (PST)
Message-ID: <20121228.203315.1058343365326793366.davem@davemloft.net>
References: <20121228202428.5aa18a7b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765Ab2L2EdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 23:33:16 -0500
In-Reply-To: <20121228202428.5aa18a7b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 28 Dec 2012 20:24:28 -0800

> Sparse detected case where this local function should be static.
> It may even allow some compiler optimizations.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
