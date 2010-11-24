From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Disable local BHes to prevent a
 dead-lock situation
Date: Wed, 24 Nov 2010 11:09:06 -0800 (PST)
Message-ID: <20101124.110906.39159145.davem@davemloft.net>
References: <1290606310.25676.7.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40795
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755548Ab0KXTIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:08:40 -0500
In-Reply-To: <1290606310.25676.7.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Wed, 24 Nov 2010 15:45:10 +0200

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> According to Eric's suggestion:
> Disable local BHes to prevent a dead-lock situation between sch_direct_xmit()
> (Soft_IRQ context) and bnx2x_tx_int (called by bnx2x_run_loopback() - syscall
> context), as both are taking a netif_tx_lock().
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
