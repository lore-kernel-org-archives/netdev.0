From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] skbuff: fix ftrace handling in skb_unshare
Date: Tue, 14 Oct 2014 13:10:43 -0400 (EDT)
Message-ID: <20141014.131043.689905508499161205.davem@davemloft.net>
References: <1412975447-29958-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbaJNRKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 13:10:45 -0400
In-Reply-To: <1412975447-29958-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Fri, 10 Oct 2014 23:10:47 +0200

> If the skb is not dropped afterwards we should run consume_skb instead
> kfree_skb. Inside of function skb_unshare we do always a kfree_skb,
> doesn't depend if skb_copy failed or was successful.
> 
> This patch switch this behaviour like skb_share_check, if allocation of
> sk_buff failed we use kfree_skb otherwise consume_skb.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>

Applied, thanks.
