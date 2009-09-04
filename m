From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] ixgbe: Add support for multiple Tx queues
 for FCoE in 82599
Date: Thu, 03 Sep 2009 20:08:09 -0700 (PDT)
Message-ID: <20090903.200809.212485138.davem@davemloft.net>
References: <20090904005549.14869.66878.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51015
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932823AbZIDDHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:07:54 -0400
In-Reply-To: <20090904005549.14869.66878.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 03 Sep 2009 17:55:50 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> This patch adds support for multiple transmit queues to the Fiber Channel
> over Ethernet (FCoE) feature found in 82599. Currently, FCoE has multiple
> Rx queues available, along with a redirection table, that helps distribute
> the I/O load across multiple CPUs based on the FC exchange ID. To make
> this the most effective, we need to provide the same layout of transmit
> queues to match receive.
> 
> Particularly, when Data Center Bridging (DCB) is enabled, the designated
> traffic class for FCoE can have dedicated queues for just FCoE traffic,
> while not affecting any other type of traffic flow.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

So does this eat into the TX queues available to non-FCOE traffic
or is this a shared setup?
