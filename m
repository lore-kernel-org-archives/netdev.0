From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 1/3] vlan: vlan device not reading gso max
 size of parent.
Date: Thu, 11 Sep 2008 20:17:16 -0700 (PDT)
Message-ID: <20080911.201716.117929885.davem@davemloft.net>
References: <20080912030733.6982.49986.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40759
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751813AbYILDRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:17:23 -0400
In-Reply-To: <20080912030733.6982.49986.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 11 Sep 2008 20:07:47 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The vlan devices are not reading the gso max size of the parent device.  As
> a result devices that do not support 64K max gso size are currently
> failing.
> 
> This issue is seen on 2.6.26 kernels as well and the same patch should be
> able to be applied without any issues.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Good catch, applied to net-next-2.6
