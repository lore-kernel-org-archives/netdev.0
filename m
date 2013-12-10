From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: drop_monitor: fix the value of maxattr
Date: Mon, 09 Dec 2013 21:11:20 -0500 (EST)
Message-ID: <20131209.211120.60565860491792737.davem@davemloft.net>
References: <1386513416-97719-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094Ab3LJCLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:11:21 -0500
In-Reply-To: <1386513416-97719-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sun,  8 Dec 2013 09:36:56 -0500

> maxattr in genl_family should be used to save the max attribute
> type, but not the max command type. Drop monitor doesn't support
> any attributes, so we should leave it as zero.

Please provide a proper signoff next time.

Applied, and queued up for -stable, thanks.
