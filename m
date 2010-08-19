From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 02/20] ixgbe: remove redundant DMA
 alignment code
Date: Thu, 19 Aug 2010 16:45:58 -0700 (PDT)
Message-ID: <20100819.164558.189718091.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233339.10335.17698.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753018Ab0HSXpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:45:42 -0400
In-Reply-To: <20100819233339.10335.17698.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:33:41 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch removes the redundant DMA alignment code from the Rx buffer
> allocation path.  This code is no longer necessary since all x86 buffers
> are now DMA aligned due to recent changes to NET_IP_ALIGN and NET_SKB_PAD.
> 
> It also moves the setting of the Rx queue value into the allocation path
> since it is more likely that the queue mapping will still be in the cache
> at the time of allocation.
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
