From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: Use irq_synchronize per vector when
 using MSI-X
Date: Mon, 02 Aug 2010 21:21:29 -0700 (PDT)
Message-ID: <20100802.212129.55855432.davem@davemloft.net>
References: <20100803004044.4441.34335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	jdelvare@suse.de, emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754155Ab0HCEVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 00:21:11 -0400
In-Reply-To: <20100803004044.4441.34335.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 02 Aug 2010 17:40:52 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Synchronize all IRQs when using MSI-X. Similar to ixgbe.
> Issue was reported on e1000e, but the patch is also valid for igb.
> 
> CC: Jean Delvare <jdelvare@suse.de>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
