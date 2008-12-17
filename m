From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Add irda_skb_cb qdisc related padding
Date: Wed, 17 Dec 2008 15:45:08 -0800 (PST)
Message-ID: <20081217.154508.87177275.davem@davemloft.net>
References: <20081217224906.GA5783@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752308AbYLQXpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 18:45:06 -0500
In-Reply-To: <20081217224906.GA5783@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Ortiz <samuel@sortiz.org>
Date: Wed, 17 Dec 2008 23:49:06 +0100

> We need to pad irda_skb_cb in order to keep it safe accross dev_queue_xmit()
> calls. This is some ugly and temporary hack triggered by recent qisc code
> changes.
> Even though it fixes bugzilla.kernel.org bug #11795, it will be replaced by a
> proper fix before 2.6.29 is released.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thanks Samuel.
