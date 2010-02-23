From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000: Fix DMA mapping error handling on RX
Date: Tue, 23 Feb 2010 01:25:17 -0800 (PST)
Message-ID: <20100223.012517.102934961.davem@davemloft.net>
References: <20100220035423.31265.13034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, anton@samba.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750909Ab0BWJY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 04:24:59 -0500
In-Reply-To: <20100220035423.31265.13034.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Feb 2010 19:54:53 -0800

> From: Anton Blanchard <anton@samba.org>
> 
> Check for error return from pci_map_single/pci_map_page and clean up.
> 
> With this and the previous patch the driver was able to handle a significant
> percentage of errors (I set the fault injection rate to 10% and could still
> download large files at a reasonable speed).
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
