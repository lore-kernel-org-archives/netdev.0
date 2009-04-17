From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: Fix DCB traffic class mapping for
 82599
Date: Fri, 17 Apr 2009 01:17:52 -0700 (PDT)
Message-ID: <20090417.011752.165813044.davem@davemloft.net>
References: <20090417010019.19018.62374.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com, stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49857
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754561AbZDQISA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:18:00 -0400
In-Reply-To: <20090417010019.19018.62374.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Apr 2009 18:00:20 -0700

> The traffic classes in hardware are not symmetrical for Rx and Tx.  Rx
> is every 16 descriptor queues, Tx is not.  It runs 32-32-16-16-8-8-8 when
> running with 8 traffic classes, and runs 64-32-16 when running with 4
> traffic classes.  This patch fixes the mapping.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
