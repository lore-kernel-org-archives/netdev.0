From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 4/5] e1000e: e1000e_enable_tx_pkt_filtering()
 returns wrong value
Date: Fri, 08 Jan 2010 00:39:51 -0800 (PST)
Message-ID: <20100108.003951.202533306.davem@davemloft.net>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
	<20100108023153.31476.89128.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34895
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752358Ab0AHIjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:39:43 -0500
In-Reply-To: <20100108023153.31476.89128.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 Jan 2010 18:31:54 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> e1000e_enable_tx_pkt_filtering() will return a non-zero value if the
> driver fails to enable the manageability interface on the host for
> any reason; instead it should retun zero to indicate filtering has been
> disabled.  Also provide a single exit point for the function.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
