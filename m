From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] e1000e: stop cleaning when we reach
 tx_ring->next_to_use
Date: Thu, 01 Apr 2010 19:33:55 -0700 (PDT)
Message-ID: <20100401.193355.255461107.davem@davemloft.net>
References: <4BB3AA30.3060906@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: terry.loftin@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757471Ab0DBCdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 22:33:54 -0400
In-Reply-To: <4BB3AA30.3060906@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Terry Loftin <terry.loftin@hp.com>
Date: Wed, 31 Mar 2010 14:01:52 -0600

> Tx ring buffers after tx_ring->next_to_use are volatile and could
> change, possibly causing a crash.  Stop cleaning when we hit
> tx_ring->next_to_use.
> 
> Signed-off-by: Terry Loftin <terry.loftin@hp.com>

Intel folks please look carefully at this fix.  I want to
get it into net-2.6 if it's correct.

Thanks.
