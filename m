From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] Read back MSI message in rtas_setup_msi_irqs() so restore works
Date: Wed, 7 Nov 2007 15:29:49 -0600
Message-ID: <20071107212949.GI4239@austin.ibm.com>
References: <5f47235ce3542c80e043f7f183400ab3d576f1dd.1193113342.git.michael@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	mchan@broadcom.com, mcarlson@broadcom.com,
	linux-pci@atrey.karlin.mff.cuni.cz,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:55274 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999AbXKGVaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 16:30:15 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA7LTpnk021809
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 16:29:51 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA7LTpTn500950
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 16:29:51 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA7LTnQw014498
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 16:29:50 -0500
Content-Disposition: inline
In-Reply-To: <5f47235ce3542c80e043f7f183400ab3d576f1dd.1193113342.git.michael@ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 23, 2007 at 02:23:44PM +1000, Michael Ellerman wrote:
> There are plans afoot to use pci_restore_msi_state() to restore MSI
> state after a device reset. In order for this to work for the RTAS MSI
> backend, we need to read back the MSI message from config space after
> it has been setup by firmware.
> 
> This should be sufficient for restoring the MSI state after a device
> reset, however we will need to revisit this for suspend to disk if that
> is ever implemented on pseries.
> 
> Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
> ---
> 
> Linas, can you test this on your setup with your EEH stuff? I haven't got
> any MSI supporting hardware/firmware combination.

Acked-by: Linas Vepstas <linas@austin.ibm.com>

I *finally* was able to get onto some hardware long enough to run this.
And that took a lot of work. Sigh. Yes, this is exactly what I'd wanted.

--linas
