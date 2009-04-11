From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/10] ixgbe: Remove unnecessary PHY reset, properly
 identify multispeed fiber modules
Date: Sat, 11 Apr 2009 02:51:05 -0700 (PDT)
Message-ID: <20090411.025105.89408494.davem@davemloft.net>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
	<20090410082815.14372.18601.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58389
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757539AbZDKJvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 05:51:14 -0400
In-Reply-To: <20090410082815.14372.18601.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Apr 2009 01:28:15 -0700

> This patch does two things:
> 1) On 82599, the PHY is emedded in the MAC.  On 82598, the SFP+ NIC has an external PHY.  The reset in the SFP+ setup patch for 82598 is unnecessary on 82599, and adds extra dead time to device initialization.  This removes that PHY reset for 82599 only.
> 
> 2) On 82599, the SFP+ modules are multispeed fiber modules (10G/1G).  We need to make sure to identify them properly for the remaining init sections to properly set them up.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6
