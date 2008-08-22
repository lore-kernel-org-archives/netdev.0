From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] ip: skip IP checksum for skbs with
 CHECKSUM_UNNECESSARY set
Date: Fri, 22 Aug 2008 15:53:50 -0700 (PDT)
Message-ID: <20080822.155350.195324904.davem@davemloft.net>
References: <200808222224.32311.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40523
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751997AbYHVWxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 18:53:52 -0400
In-Reply-To: <200808222224.32311.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Fri, 22 Aug 2008 22:24:31 +0300

> We are working on a completely in hardware LRO implementation and this patch 
> would simplify the hardware implementation. Is this acceptable?

This is not worth the bother, otherwise we would have done it a long
time ago.

Please provide a correct IP header checksum in your hw LRO implementation.
