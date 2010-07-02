From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/5] igb: Fix Tx hangs seen when loading
 igb with max_vfs > 7.
Date: Thu, 01 Jul 2010 22:50:09 -0700 (PDT)
Message-ID: <20100701.225009.140752510.davem@davemloft.net>
References: <20100701233733.16171.4629.stgit@localhost.localdomain>
	<20100701233838.16171.90269.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49330
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755333Ab0GBFtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:49:55 -0400
In-Reply-To: <20100701233838.16171.90269.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 16:38:40 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Check the value of max_vfs at the time of assignment of vfs_allocated_count.
> 
> The previous check in igb_probe_vfs was too late as by that time the rx/tx
> rings were initialized with the wrong offset.
> 
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
