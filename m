From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igb/igbvf: cleanup exception handling in
 tx_map_adv
Date: Sat, 23 Jan 2010 01:35:07 -0800 (PST)
Message-ID: <20100123.013507.239395993.davem@davemloft.net>
References: <20100123093225.11466.42278.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36049
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742Ab0AWJe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:34:56 -0500
In-Reply-To: <20100123093225.11466.42278.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 01:32:51 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> After removing the skb_dma_map/unmap calls the exception handling in
> igb_tx_map_adv is not correct.  The issue is that the count value was not
> being correctly handled so as a result we were not rewinding the ring as
> back as we should have been.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
