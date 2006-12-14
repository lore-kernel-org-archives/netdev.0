From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][BNX2]: Fix panic in bnx2_tx_int().
Date: Thu, 14 Dec 2006 15:57:17 -0800 (PST)
Message-ID: <20061214.155717.94073310.davem@davemloft.net>
References: <1166063433.30522.5.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agospoda@redhat.com, netdev@vger.kernel.org, cjk@techma.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750960AbWLOA2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 19:28:55 -0500
To: mchan@broadcom.com
In-Reply-To: <1166063433.30522.5.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 13 Dec 2006 18:30:33 -0800

> [BNX2]: Fix panic in bnx2_tx_int().
> 
> There was an off-by-one bug in bnx2_tx_avail().  If the tx ring is
> completely full, the producer and consumer indices may be apart by
> 256 even though the ring size is only 255.  One entry in the ring is
> unused and must be properly accounted for when calculating the number
> of available entries.  The bug caused the tx ring entries to be
> reused by mistake, overwriting active entries, and ultimately causing
> it to crash.
> 
> This bug rarely occurs because the tx ring is rarely completely full.
> We always stop when there is less than MAX_SKB_FRAGS entries available
> in the ring.
> 
> Thanks to Corey Kovacs <cjk@techma.com> and Andy Gospodarek
> <agospoda@redhat.com> for reporting the problem and helping to collect
> debug information.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
