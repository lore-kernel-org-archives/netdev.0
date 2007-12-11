From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][BNX2]: Fix RX packet rot.
Date: Mon, 10 Dec 2007 17:19:13 -0800 (PST)
Message-ID: <20071210.171913.245036734.davem@davemloft.net>
References: <1197235034.20251.10.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752399AbXLKBTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 20:19:13 -0500
In-Reply-To: <1197235034.20251.10.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 09 Dec 2007 13:17:14 -0800

> [BNX2]: Fix RX packet rot.
> 
> Packets can be left in the RX ring if the NAPI budget is reached.
> This is caused by storing the latest rx index at the beginning of
> bnx2_rx_int().  We may not process all the work up to this index
> if the budget is reached and so some packets in the RX ring may rot
> when we later check for more work using this stored rx index.
> 
> The fix is to not store this latest hw index and only store the
> processed rx index.  We use a new function bnx2_get_hw_rx_cons()
> to fetch the latest hw rx index.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
