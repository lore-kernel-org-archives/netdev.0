From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] e1000: call pci_save_state after
 pci_restore_state
Date: Wed, 03 Feb 2010 19:47:22 -0800 (PST)
Message-ID: <20100203.194722.234055578.davem@davemloft.net>
References: <20100204004926.16084.32526.stgit@localhost.localdomain>
	<20100204004947.16084.75922.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	nicholasx.d.nunley@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756408Ab0BDDrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:47:08 -0500
In-Reply-To: <20100204004947.16084.75922.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 03 Feb 2010 16:49:48 -0800

> From: Nick Nunley <nicholasx.d.nunley@intel.com>
> 
> This patch adds a call to pci_save_state() immediately after
> the call to pci_restore_state(). Due to a change in the behavior
> of pci_restore_state() it is necessary to call pci_save_state()
> to keep the state_saved flag. This patch is based on a similar
> patch for ixgbe.
> 
> Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
