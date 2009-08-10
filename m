From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] ixgbe: Disable packet split only on FCoE
 queues in 82599
Date: Sun, 09 Aug 2009 21:53:29 -0700 (PDT)
Message-ID: <20090809.215329.23373396.davem@davemloft.net>
References: <20090806230514.28347.51172.stgit@localhost.localdomain>
	<20090806230544.28347.97373.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752474AbZHJExT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:53:19 -0400
In-Reply-To: <20090806230544.28347.97373.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 06 Aug 2009 16:05:44 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> For 82599, packet split has to be disabled for FCoE direct data placement.
> However, this is only required on received queues allocated for FCoE. This
> patch adds a per ring flags to indicate if packet split is disabled on a
> per queue basis, particularly for FCoE, as packet split must be disabled
> for large receive using direct data placement (DDP).
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
