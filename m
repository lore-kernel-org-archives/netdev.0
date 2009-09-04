From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] ixgbe: Distribute transmission of FCoE
 traffic in 82599
Date: Thu, 03 Sep 2009 20:09:15 -0700 (PDT)
Message-ID: <20090903.200915.157113657.davem@davemloft.net>
References: <20090904005549.14869.66878.stgit@localhost.localdomain>
	<20090904005609.14869.89202.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51018
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932698AbZIDDJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:09:00 -0400
In-Reply-To: <20090904005609.14869.89202.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 03 Sep 2009 17:56:10 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> This adds a simple selection of a FCoE tx queue based on the current cpu id to
> distribute transmission of FCoE traffic evenly among multiple FCoE transmit
> queues.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

Does it matter that arbitrary programs or other stacks could transmit
ETH_P_FCOE traffic as well?  Would that interfere with how this offload
hardware works now that you're directing all ETH_P_FCOE traffic to
FCOE rings?
