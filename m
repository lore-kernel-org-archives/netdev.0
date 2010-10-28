From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: DCB, fix TX hang occurring in stress
 condition with PFC
Date: Thu, 28 Oct 2010 10:20:34 -0700 (PDT)
Message-ID: <20101028.102034.183041365.davem@davemloft.net>
References: <20101028105957.27748.39154.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45563
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933965Ab0J1RUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:20:10 -0400
In-Reply-To: <20101028105957.27748.39154.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 28 Oct 2010 03:59:57 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> The DCB credits refill quantum _must_ be greater than half the max
> packet size. This is needed to guarantee that TX DMA operations
> are not attempted during a pause state. Additionally, the min IFG
> must be set correctly for DCB mode. If a DMA operation is
> requested unexpectedly during the pause state the HW data
> store may be corrupted leading to a DMA hang.  The DMA hang
> requires a reset to correct. This fixes the HW configuration
> to avoid this condition.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
