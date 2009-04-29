From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ixgbe: Use pci_wake_from_d3() instead of
 multiple pci_enable_wake()
Date: Wed, 29 Apr 2009 00:22:39 -0700 (PDT)
Message-ID: <20090429.002239.150859712.davem@davemloft.net>
References: <20090429071852.6130.6565.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752154AbZD2HWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 03:22:46 -0400
In-Reply-To: <20090429071852.6130.6565.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 29 Apr 2009 00:18:52 -0700

> We were calling pci_enable_wake() twice in a row for both D3_hot
> and D3_cold.  This replaces those calls with a call to pci_wake_from_d3()
> to avoid issues with PCI PM vs ordering constraints.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
