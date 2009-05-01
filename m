From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add the FCoE Initialization Protocol ethertype
Date: Fri, 01 May 2009 15:56:01 -0700 (PDT)
Message-ID: <20090501.155601.205697782.davem@davemloft.net>
References: <20090501185532.14602.21059.stgit@fritz>
	<20090501.150454.224636608.davem@davemloft.net>
	<273D38FBE7C6FE46A1689FCD014A0B8B495C012C@azsmsx505.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley@HansenPartnership.com, netdev@vger.kernel.org
To: robert.w.love@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59323
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754586AbZEAW4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:56:07 -0400
In-Reply-To: <273D38FBE7C6FE46A1689FCD014A0B8B495C012C@azsmsx505.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Love, Robert W" <robert.w.love@intel.com>
Date: Fri, 1 May 2009 15:53:32 -0700

> The FIP implementation is upstream, in drivers/scsi/libfcoe.c.
> There is a local define in include/scsi/fc/fc_fip.h for ETH_P_FCOE
> and I'd rather move it to the propper location.

Then add that local definition removal to your patch so there is
no mystery about what this is used for.

> I can refresh this patch to include the fc_fip.h removal and you and
> James can decide who takes the patch if that's a better aproach.

That works much better, and to avoid merge issues you can send it
via James with my pre-ack:

Acked-by: David S. Miller <davem@davemloft.net>
