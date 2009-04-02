From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] ixgbe: Fix DCB netlink layer for 82599 to enable
 Priority Flow Control
Date: Thu, 02 Apr 2009 01:15:28 -0700 (PDT)
Message-ID: <20090402.011528.209050325.davem@davemloft.net>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
	<20090401073325.3749.28376.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755517AbZDBIPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:15:39 -0400
In-Reply-To: <20090401073325.3749.28376.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:33:25 -0700

> The priority flow control settings from the netlink layer aren't taking
> effect in the base driver.  The boolean pfc_mode_enable in the dcb_config
> struct isn't being set, so the hardware configuration code is never
> reached.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
