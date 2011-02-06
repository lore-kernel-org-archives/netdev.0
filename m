From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bnx2x: Duplication in promisc mode
Date: Sun, 06 Feb 2011 11:21:56 -0800 (PST)
Message-ID: <20110206.112156.115927987.davem@davemloft.net>
References: <1296998053.16759.25.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53079
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753536Ab1BFTVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Feb 2011 14:21:21 -0500
In-Reply-To: <1296998053.16759.25.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 6 Feb 2011 15:14:13 +0200

> Prevent packets duplication for frames targeting FCoE L2 ring:
> packets were arriving to stack from both L2 RSS and from FCoE
> L2 in a promiscuous mode.
> 
> Configure FCoE L2 ring to DROP_ALL rx mode, when interface is
> configured to PROMISC, and to accept only unicast frames, when
> interface is configured to ALL_MULTI.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
