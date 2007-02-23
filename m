From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: natsemi: Fix detection of vanilla natsemi cards
Date: Fri, 23 Feb 2007 14:26:22 +0000
Message-ID: <20070223142621.GD9282@sirena.org.uk>
References: <20070223113209.GB9282@sirena.org.uk> <20070223134740.E5ECADBA1@gherkin.frus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Tim Hockin <thockin@hockin.org>,
	Jeff Garzik <jgarzik@pobox.com>, Adrian Bunk <bunk@stusta.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bob Tracy <rct@gherkin.frus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4828 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932402AbXBWO1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 09:27:06 -0500
Content-Disposition: inline
In-Reply-To: <20070223134740.E5ECADBA1@gherkin.frus.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 23, 2007 at 07:47:40AM -0600, Bob Tracy wrote:

> ACK except for a missing comma at the end of the line being replaced,
> which prevents the patch from applying cleanly.  Otherwise, this fixes
> the problem I was having.  Thanks!

Aargh.

--- linux.orig/drivers/net/natsemi.c	2007-02-23 11:13:03.000000000 +0000
+++ linux/drivers/net/natsemi.c	2007-02-23 11:12:00.000000000 +0000
@@ -260,7 +260,7 @@
 
 static const struct pci_device_id natsemi_pci_tbl[] __devinitdata = {
 	{ PCI_VENDOR_ID_NS, 0x0020, 0x12d9,     0x000c,     0, 0, 0 },
-	{ PCI_VENDOR_ID_NS, 0x0020, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_NS, 0x0020, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, natsemi_pci_tbl);

-- 
"You grabbed my hand and we fell into it, like a daydream - or a fever."
