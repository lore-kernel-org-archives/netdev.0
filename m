From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: stop cleaning when we reach
 tx_ring->next_to_use
Date: Tue, 13 Apr 2010 03:09:08 -0700 (PDT)
Message-ID: <20100413.030908.140469864.davem@davemloft.net>
References: <20100409202917.31293.79618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, terry.loftin@hp.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49659
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752530Ab0DMKJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:09:04 -0400
In-Reply-To: <20100409202917.31293.79618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 09 Apr 2010 13:29:49 -0700

> From: Terry Loftin <terry.loftin@hp.com>
> 
> Tx ring buffers after tx_ring->next_to_use are volatile and could
> change, possibly causing a crash.  Stop cleaning when we hit
> tx_ring->next_to_use.
> 
> Signed-off-by: Terry Loftin <terry.loftin@hp.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
