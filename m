From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH][RESEND] igb: remove ASPM L0s workaround
Date: Sat, 14 Mar 2009 12:54:45 -0700 (PDT)
Message-ID: <20090314.125445.99853912.davem@davemloft.net>
References: <20090314063308.3837.66924.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46712
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753968AbZCNTy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 15:54:59 -0400
In-Reply-To: <20090314063308.3837.66924.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 13 Mar 2009 23:35:34 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The L0s workaround should be moved into a pci quirk and so it is not
> necessary in the driver.  This update removes the L0s workaround from the
> igb driver.
> 
> This was the second half of the PCI quirk patch with Matthew Wilcox did not
> pick up when he picked up the quirk patch.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Doesn't apply to net-2.6:

davem@sunset:~/src/GIT/net-2.6$ apply "Alexander Duyck" "alexander.h.duyck@intel.com" diff msg
error: patch failed: drivers/net/igb/igb_main.c:1126
error: drivers/net/igb/igb_main.c: patch does not apply
davem@sunset:~/src/GIT/net-2.6$ 

And in fact if I try to apply it to net-next-2.6, that does
work.
