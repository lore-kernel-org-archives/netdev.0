From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix Need to call pci_save_state after
 pci_restore_state
Date: Wed, 23 Dec 2009 21:19:34 -0800 (PST)
Message-ID: <20091223.211934.27812242.davem@davemloft.net>
References: <20091222204456.14196.63456.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60654
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751265AbZLXFTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 00:19:32 -0500
In-Reply-To: <20091222204456.14196.63456.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 22 Dec 2009 12:45:20 -0800

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> This patch adds a pci_save_state() call in ixgbe_resume() after
> pci_restore_state(). A similar change was made in ixgbe_io_slot_reset()
> that accommodates pci_restore_state() new behavior. This change makes
> pci_restore_state() clear the saved_state flag This is necessary due
> to a resent kernel change to pci_restore_state() so that it now clears
> the saved_state flag of the device right after the device.s standard
> configuration registers have been poplulated with the previously saved
> values.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
