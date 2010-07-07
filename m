From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] bnx2x: Set RXHASH for LRO packets
Date: Wed, 07 Jul 2010 15:45:32 -0700 (PDT)
Message-ID: <20100707.154532.67891779.davem@davemloft.net>
References: <1278425383.22257.4.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47614
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756482Ab0GGWpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 18:45:18 -0400
In-Reply-To: <1278425383.22257.4.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Tue, 6 Jul 2010 17:09:43 +0300

> Set Toeplitz hash both for LRO and none-LRO skbs.
> The first CQE (TPA_START) will contain a hash for an LRO packet.
> 
> Current code sets skb->rx_hash for none-LRO skbs only.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
