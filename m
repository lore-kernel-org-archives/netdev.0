From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [2.6.18 backport] RTL8168 ethernet support in r8169
Date: Tue, 26 Sep 2006 21:14:58 +0200
Message-ID: <20060926191458.GB15039@electric-eye.fr.zoreil.com>
References: <451972B0.5020805@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:21712 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932396AbWIZTRp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 15:17:45 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <451972B0.5020805@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake <dsd@gentoo.org> :
[...]
 static struct pci_device_id rtl8169_pci_tbl[] = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), },
-	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), },
-	{ PCI_DEVICE(0x16ec,			0x0116), },
-	{ PCI_VENDOR_ID_LINKSYS,		0x1032, PCI_ANY_ID, 0x0024, },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_1 },

Should be RTL_CFG_2 (but there are still issues with the link management).

+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_1 },
                                                               ^^^^^^^^^
Should be RTL_CFG_1.

Is there any chance that you can push a different patch for your releases ?

There are no pending changes outside of the git vanilla tree. As an option,
you can use the patch below too:
http://www.fr.zoreil.com/people/francois/misc/20060920-2.6.18-r8169-test.patch

I should have Cced: you :o/

--
Ueimor
