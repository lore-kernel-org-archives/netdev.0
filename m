From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] e1000: fix occasional panic on unload
Date: Thu, 23 Sep 2010 14:34:28 -0700 (PDT)
Message-ID: <20100923.143428.124066088.davem@davemloft.net>
References: <20100923042126.11798.49675.stgit@localhost.localdomain>
	<20100923042240.11798.65680.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38124
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753041Ab0IWVeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:34:09 -0400
In-Reply-To: <20100923042240.11798.65680.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 21:22:42 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Net drivers in general have an issue where timers fired
> by mod_timer or work threads with schedule_work are running
> outside of the rtnl_lock.
> 
> With no other lock protection these routines are vulnerable
> to races with driver unload or reset paths.
> 
> The longer term solution to this might be a redesign with
> safer locks being taken in the driver to guarantee no
> reentrance, but for now a safe and effective fix is
> to take the rtnl_lock in these routines.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
