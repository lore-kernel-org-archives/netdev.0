From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/5] e1000e: call pci_save_state() after
 pci_restore_state()
Date: Fri, 08 Jan 2010 00:39:35 -0800 (PST)
Message-ID: <20100108.003935.46537110.davem@davemloft.net>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752142Ab0AHIj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:39:27 -0500
In-Reply-To: <20100108023033.31476.4034.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 Jan 2010 18:30:56 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Due to a change in pci_restore_state()[1] which clears the saved_state
> flag, the driver should call pci_save_state() to set the flag once again
> to avoid issues with EEH (same fix that recently was submitted for ixgbe).
> 
> [1] commmit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
