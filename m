From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] e1000e: 82579 performance improvements
Date: Thu, 30 Sep 2010 21:17:03 -0700 (PDT)
Message-ID: <20100930.211703.209987753.davem@davemloft.net>
References: <20100930073814.13378.4212.stgit@localhost.localdomain>
	<20100930073934.13378.44230.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48266
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751086Ab0JAEQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 00:16:42 -0400
In-Reply-To: <20100930073934.13378.44230.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 30 Sep 2010 00:39:37 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The initial support for 82579 was tuned poorly for performance.  Adjust the
> packet buffer allocation appropriately for both standard and jumbo frames;
> and for jumbo frames increase the receive descriptor pre-fetch, disable
> adaptive interrupt moderation and set the DMA latency tolerance.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
