From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/5] igb: fix unmap length bug
Date: Tue, 30 Jun 2009 19:53:28 -0700 (PDT)
Message-ID: <20090630.195328.01505382.davem@davemloft.net>
References: <20090630224515.17771.76848.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753027AbZGACxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 22:53:22 -0400
In-Reply-To: <20090630224515.17771.76848.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Jun 2009 15:45:15 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> driver was mixing NET_IP_ALIGN count bytes in map/unmap calls
> unevenly. Only map the bytes that the hardware might dma into
> 
> also fix unmap related bug where ->dma was not being cleared
> after unmap
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
