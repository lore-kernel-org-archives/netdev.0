From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] ixgbe: if ixgbe_copy_dcb_cfg is going to
 fail learn about it early
Date: Thu, 28 Jan 2010 05:57:03 -0800 (PST)
Message-ID: <20100128.055703.127968273.davem@davemloft.net>
References: <20100128023717.19441.27328.stgit@localhost.localdomain>
	<20100128023805.19441.23796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56902
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756224Ab0A1N4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 08:56:51 -0500
In-Reply-To: <20100128023805.19441.23796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 27 Jan 2010 18:38:06 -0800

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Call ixgbe_copy_dcb_cfg() earlier in the ixgbe_dcbnl_set_all() so that
> we can learn if this is going to fail as early as possible.  Previously,
> ixgbe_down or ixgbe_close were being called before this check and the
> IXGBE_RESETTING bit was being set and cleared.  Worse if this failed
> the corresponding ixgbe_up/ndo_open would not called.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
