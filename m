From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/5] ixgbe: dcb, set DPF bit when PFC is
 enabled
Date: Mon, 19 Jul 2010 20:24:11 -0700 (PDT)
Message-ID: <20100719.202411.163227657.davem@davemloft.net>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	john.r.fastabend@intel.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758162Ab0GTDX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 23:23:56 -0400
In-Reply-To: <20100719235831.14112.14175.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jul 2010 16:59:03 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Set the DPF bit when PFC is enabled.  This will discard
> PFC frames so they do not get passed up the stack.
> 
> The DPF bit is set for flow control, but not priority
> flow control this brings pfc inline with fc.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
