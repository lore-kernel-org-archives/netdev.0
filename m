From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000e: correct MAC-PHY interconnect
 register offset for 82579
Date: Tue, 03 Aug 2010 16:41:10 -0700 (PDT)
Message-ID: <20100803.164110.112582904.davem@davemloft.net>
References: <20100803214827.5712.8674.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57636
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757872Ab0HCXkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 19:40:51 -0400
In-Reply-To: <20100803214827.5712.8674.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 03 Aug 2010 14:48:35 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The MAC-PHY interconnect register set on ICH/PCH parts is accessed through
> a peephole mechanism by writing an offset to a CSR register.  The offset
> for the interconnect's half-duplex control register (which is used in a
> jumbo frame workaround for 82579) is incorrect.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
