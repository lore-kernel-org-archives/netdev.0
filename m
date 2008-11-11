From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix setting of skb->tail in skb_recycle_check()
Date: Mon, 10 Nov 2008 21:45:15 -0800 (PST)
Message-ID: <20081110.214515.88409073.davem@davemloft.net>
References: <20081108230943.GW32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@ddcrew.com, dirk@upexia.nl
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51055
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753168AbYKKFpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 00:45:15 -0500
In-Reply-To: <20081108230943.GW32552@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Sun, 9 Nov 2008 00:09:43 +0100

> Since skb_reset_tail_pointer() reads skb->data, we need to set
> skb->data before calling skb_reset_tail_pointer().  This was causing
> spurious skb_over_panic()s from skb_put() being called on a recycled
> skb that had its skb->tail set to beyond where it should have been.
> 
> Bug report from Peter van Valderen <linux@ddcrew.com>.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied, thanks a lot Lennert!
