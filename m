From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Do Tx handling in a separate tasklet.
Date: Sun, 25 Oct 2009 14:20:59 -0700 (PDT)
Message-ID: <20091025.142059.175260055.davem@davemloft.net>
References: <1256473182.11634.4.camel@lb-tlvb-vladz.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41172
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753707AbZJYVUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 17:20:36 -0400
In-Reply-To: <1256473182.11634.4.camel@lb-tlvb-vladz.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 25 Oct 2009 14:19:42 +0200

> This patch moves the 'Tx interrupt work' of each Tx queue from the hardIRQ
> context to the separate low-latency tasklet. Otherwise there is a possibility
> of a software lockup situation in a Tx softIRQ as it handles freeing all skb's
> 'freed' in (hard)IRQ context.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Use NAPI, please...
