From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/4] e1000e: don't inadvertently re-set
 INTX_DISABLE
Date: Tue, 29 Jun 2010 23:14:44 -0700 (PDT)
Message-ID: <20100629.231444.35810959.davem@davemloft.net>
References: <20100630040959.8652.31147.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	dnelson@redhat.com, stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59103
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751009Ab0F3GOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 02:14:33 -0400
In-Reply-To: <20100630040959.8652.31147.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 29 Jun 2010 21:12:05 -0700

> From: Dean Nelson <dnelson@redhat.com>
> 
> Should e1000_test_msi() fail to see an msi interrupt, it attempts to
> fallback to legacy INTx interrupts. But an error in the code may prevent
> this from happening correctly.
...
> The solution is to have e1000_test_msi() re-read the PCI_COMMAND bits as
> part of its attempt to re-enable SERR.
> 
> During debugging/testing of this issue I found that not all the systems
> I ran on had the SERR bit set to begin with. And on some of the systems
> the same could be said for the INTX_DISABLE bit. Needless to say these
> latter systems didn't have a problem falling back to legacy INTx
> interrupts with the code as is.
> 
> Signed-off-by: Dean Nelson <dnelson@redhat.com>
> CC: stable@kernel.org
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
