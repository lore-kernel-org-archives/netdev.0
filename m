From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] PCIe ASPM causes machine (HP Compaq 6735s) to sometimes freeze hard at boot at PCI initialization time
Date: Fri, 5 Dec 2008 18:21:48 +0000
Message-ID: <20081205182148.GA28192@srcf.ucam.org>
References: <200811281328.55259.trenn@suse.de> <200812051407.14419.trenn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jbarnes@virtuousgeek.org,
	shaohua.li@intel.com, Rafael Wysocki <rwysocki@suse.de>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Stable@kernel.org
To: Thomas Renninger <trenn@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:56177 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbYLESVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 13:21:54 -0500
Content-Disposition: inline
In-Reply-To: <200812051407.14419.trenn@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 05, 2008 at 02:07:13PM +0100, Thomas Renninger wrote:

> PCIE: Break out of endless loop waiting for PCI config bits to switch
> 
> Makes a Compaq 6735s boot reliably again which hang in the loop
> on some boots.

Which device does it get stuck on?

> +	if (loop_count == 100) 
> +		dev_printk (KERN_WARNING, &pdev->dev, "Could not configure ASPM\n");

"ASPM: Could not configure common clock\n"? ASPM should still work, 
though with higher latency. It probably also needs to revert the 
configuration changes.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
