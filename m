From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ixgbe: fix dca issue with relaxed ordering turned
 on
Date: Mon, 19 Jan 2009 16:55:16 -0800 (PST)
Message-ID: <20090119.165516.165485763.davem@davemloft.net>
References: <20090120001101.22544.15858.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754478AbZATAzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:55:14 -0500
In-Reply-To: <20090120001101.22544.15858.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jan 2009 16:11:05 -0800

> The is an issue where setting Relaxed Ordering (RO) bit
> (in a PCI-E write transaction) on 82598 causing the chipset
> to drop DCA hints.  This patch forces RO not to be set for
> descriptors as well as payload.  This will only be in effect
> while DCA is enabled and no performance difference was
> noticed in testing.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
