From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 5/8] ixgbe: Implement FCoE Tx side offload
 features in base driver of 82599
Date: Sun, 17 May 2009 13:58:18 -0700 (PDT)
Message-ID: <20090517.135818.251057133.davem@davemloft.net>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
	<20090513231105.11416.58577.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	yi.zou@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50546
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754410AbZEQU6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 16:58:21 -0400
In-Reply-To: <20090513231105.11416.58577.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 May 2009 16:11:06 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> This patch implements the FCoE Tx side offload features in ixgbe_main.c
> to 82599 using the Tx offload infrastructure code added in the previous
> patch. This is achieved by the calling the FCoE Sequence Offload (FSO)
> function ixgbe_fso() on the transmit path of ixgbe.
> 
> This patch also includes an EEPROM check to make sure the NIC we're loading
> on is an offload-enabled SKU.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
