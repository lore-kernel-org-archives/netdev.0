From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] e1000: use work queues
Date: Thu, 23 Sep 2010 14:34:23 -0700 (PDT)
Message-ID: <20100923.143423.184835940.davem@davemloft.net>
References: <20100923042126.11798.49675.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38118
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751108Ab0IWVeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:34:04 -0400
In-Reply-To: <20100923042126.11798.49675.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 21:22:17 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> E1000 is using several timers that in a follow on patch
> will need to acquire the rtnl_lock in order to be safe.
> 
> This patch moves the timer bodies into work queues which
> will allow the next patch to add rtnl_lock.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
