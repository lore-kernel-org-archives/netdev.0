From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8169:Issues on alloc memory
Date: Fri, 07 Aug 2015 15:35:14 -0700 (PDT)
Message-ID: <20150807.153514.763798776089518142.davem@davemloft.net>
References: <1438789277-4468-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946300AbbHGWfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 18:35:15 -0400
In-Reply-To: <1438789277-4468-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <corcodel.marian@gmail.com>
Date: Wed,  5 Aug 2015 18:41:17 +0300

> +#define R8169_TX_RING_BYTES	(NUM_ARRAYS_MAX * sizeof(struct TxDesc)) /* here sizeof not reporting correct */
> +#define R8169_RX_RING_BYTES	(NUM_ARRAYS_MAX * sizeof(struct RxDesc)) /* here sizeof not reporting correct */

This comment makes the code more confusing rather than easier to
understand.

In fact I fail to see the reason for this patch, as a whole, at all.

I hate to do this, but I am explitly letting you know that I am not going
to invest any more time reviewing any submissions you make.

They are all poorly formed, lack proper complete explanations, are
buggy, or add no value at all to the driver.

And the situation is not improving.  This has been going on for several
weeks now, and I have to draw the line somewhere.
