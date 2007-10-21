From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Sun, 21 Oct 2007 16:21:31 -0700 (PDT)
Message-ID: <20071021.162131.43417026.davem@davemloft.net>
References: <1192829817.22064.559.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	linas@austin.ibm.com, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57615
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750942AbXJUXVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 19:21:18 -0400
In-Reply-To: <1192829817.22064.559.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 19 Oct 2007 14:36:56 -0700

> This patch exports the pci_restore_msi_state() function.  This function
> is needed to restore the MSI state during PCI error recovery.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I'm not so sure about this.

Perhaps, instead, you should do a pci_msi_disable() and
pci_msi_enable() in the error detection and recovery sequence.

Or, alternatively, save/restore those MSI registers by hand.

I'm trying to figure out how the E1000 driver handles this correctly,
but I can't see it just by reading it over quickly.
