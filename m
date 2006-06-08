From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Fri, 9 Jun 2006 01:41:57 +0200
Message-ID: <20060608234157.GA18591@electric-eye.fr.zoreil.com>
References: <20060601200200.A0E0689D05D@zog.reactivated.net> <20060608143133.7e36a0b7.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46741 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964875AbWFHXoy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 19:44:54 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Content-Disposition: inline
In-Reply-To: <20060608143133.7e36a0b7.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy.Dunlap <rdunlap@xenotime.net> :
[...]
> static struct pci_device_id r1000_pci_tbl[] __devinitdata = {
> 	{ 0x10ec, 0x8169, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
> 	{ 0x10ec, 0x8167, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
> 	{ 0x10ec, 0x8168, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
> 	{ 0x10ec, 0x8136, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
> 	{0,}
> };
> 
> Any reason not to include all of those?

Nothing worrying:
- 0x8167 and 0x8168 use a different PCI region;
- some phy differences. They appear when the r1000 driver is
  compared to the previous r8169 driver from realtek.

I'll pack it with other changes.

> Conversely, any reason to use the RealTek r1000 driver?

Feel free to read it and make your own mind.

-- 
Ueimor
