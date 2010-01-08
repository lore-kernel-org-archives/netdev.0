From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 5/5] e1000e: fix and commonize code for setting
 the receive address registers
Date: Fri, 08 Jan 2010 00:39:57 -0800 (PST)
Message-ID: <20100108.003957.154464999.davem@davemloft.net>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
	<20100108023213.31476.17023.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34900
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752424Ab0AHIjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:39:49 -0500
In-Reply-To: <20100108023213.31476.17023.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 Jan 2010 18:32:13 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Fix e1000e_rar_set() to flush consecutive register writes to avoid write
> combining which some parts cannot handle.  Update e1000e_init_rx_addrs()
> to call the fixed e1000e_rar_set() instead of duplicating code.
> 
> Also change e1000e_rar_set() to _not_ set the Address Valid bit if the MAC
> address is all zeros.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
