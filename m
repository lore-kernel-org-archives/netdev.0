From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/10] ixgbe: Move PHY ops initialization to centralize
 bus accesses
Date: Sat, 11 Apr 2009 02:50:49 -0700 (PDT)
Message-ID: <20090411.025049.142781252.davem@davemloft.net>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
	<20090410082757.14372.49418.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757506AbZDKJu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 05:50:58 -0400
In-Reply-To: <20090410082757.14372.49418.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Apr 2009 01:27:57 -0700

> When PHY operations are determined, the PHY must be identified.  This
> identification causes bus access, and should be contained within its own
> routines.  This also helps the 82599 PHY init paths for both SFP+ and
> KX/KX4 devices to be easier to maintain.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6
