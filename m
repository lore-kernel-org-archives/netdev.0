From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] asix: fix infinite loop in rx_fixup()
Date: Sat, 07 Jan 2012 12:15:33 -0800 (PST)
Message-ID: <20120107.121533.576189518317929450.davem@davemloft.net>
References: <1325959767-8075-1-git-send-email-aurel@gnuage.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aurel@gnuage.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab2AGUPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 15:15:40 -0500
In-Reply-To: <1325959767-8075-1-git-send-email-aurel@gnuage.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aurelien Jacobs <aurel@gnuage.org>
Date: Sat,  7 Jan 2012 19:09:27 +0100

> At this point if skb->len happens to be 2, the subsequant skb_pull(skb, 4)
> call won't work and the skb->len won't be decreased and won't ever reach 0,
> resulting in an infinite loop.
> 
> With an ASIX 88772 under heavy load, without this patch, rx_fixup() reaches
> an infinite loop in less than a minute. With this patch applied,
> no infinite loop even after hours of heavy load.
> 
> Signed-off-by: Aurelien Jacobs <aurel@gnuage.org>

Applied, thanks.
