From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] myri10ge: pci msi and express state save/restore
Date: Mon, 11 Dec 2006 09:29:09 -0500
Message-ID: <457D6B35.8000801@pobox.com>
References: <20061208085231.7aec5ce3@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46164 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935436AbWLKO3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:29:15 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061208085231.7aec5ce3@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The PCI MSI and express state are already saved and restored by the
> current versions of pci_save_state/pci_restore_state.
> Therefore it should no longer be necessary for the driver to do it.
> This patch has not been tested on the hardware.
> 
> On suspend, handle pci_set_power_state errors, and on resume
> handle failures in pci_resume_state().
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Since Brice is an active maintainer, I would prefer to receive this 
patch via Brice.  I have a pile of patches from him, and don't want to 
invalidate that pile for this patch, even though this patch looks fairly 
sane to me.

	Jeff



