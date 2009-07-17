From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/4] ixgbe: Make sure boolean assignments
 from bitwise operations done correctly
Date: Fri, 17 Jul 2009 09:47:59 -0700 (PDT)
Message-ID: <20090717.094759.72150118.davem@davemloft.net>
References: <20090717014951.24074.75893.stgit@localhost.localdomain>
	<20090717015032.24074.41324.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53580
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934716AbZGQQry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 12:47:54 -0400
In-Reply-To: <20090717015032.24074.41324.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Jul 2009 18:50:32 -0700

> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> When the link comes up, the driver detects which flow control settings are
> active.  This is done using bitwise operations directly from the hardware
> registers, and assumes the proper boolean assignment.  Make this an
> explicit boolean value before assignment to the bool.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
