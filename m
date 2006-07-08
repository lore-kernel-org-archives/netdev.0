From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Sat, 08 Jul 2006 13:32:23 -0700 (PDT)
Message-ID: <20060708.133223.35527292.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC093F9B4@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ravinandan.arakali@neterion.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36573
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030349AbWGHUcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 16:32:39 -0400
To: mchan@broadcom.com
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093F9B4@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 7 Jul 2006 18:01:34 -0700

> However, Large Receive Offload will be a different story.  If
> packets are accumulated in the hardware and presented to the stack
> as one large packet, the stack will not be able to calculate the
> cumulative NS correctly.  Unless the hardware calculates the partial
> NS over the LRO packet and puts it in the SKB when handing over the
> packet.

This is correct, LRO hardware would need to do something to make sure
the nonce parity works out.
