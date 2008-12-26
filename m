From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 1/3] net: Init NAPI dev_list on napi_del
Date: Fri, 26 Dec 2008 01:35:44 -0800 (PST)
Message-ID: <20081226.013544.108459397.davem@davemloft.net>
References: <20081225090204.13754.25244.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41321
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753033AbYLZJfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 04:35:41 -0500
In-Reply-To: <20081225090204.13754.25244.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 25 Dec 2008 01:02:04 -0800

> The recent GRO patches introduced the NAPI removal of devices in
> free_netdev.  For drivers that can change the number of queues during
> driver operation, the NAPI infrastructure doesn't allow the freeing and
> re-addition of NAPI entities without reloading the driver.
> 
> This change reinitializes the dev_list in each NAPI struct on delete,
> instead of just deleting it (and assigning the list pointers to POISON).
> Drivers that wish to remove/re-add NAPI will need to re-initialize the
> netdev napi_list after removing all NAPI instances, before re-adding NAPI
> devices again.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
