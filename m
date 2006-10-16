From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Mon, 16 Oct 2006 11:59:53 +0100
Message-ID: <1160996393.24237.17.camel@localhost.localdomain>
References: <1160161519800-git-send-email-matthew@wil.cx>
	 <200610151545.59477.david-b@pacbell.net>
	 <20061015161834.f96a0761.akpm@osdl.org>
	 <200610151716.36337.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, matthew@wil.cx,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:56538 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1750825AbWJPKdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 06:33:17 -0400
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <200610151716.36337.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Sul, 2006-10-15 am 17:16 -0700, ysgrifennodd David Brownell:
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

Acked-by: Alan Cox <alan@redhat.com>
> 
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -499,7 +499,7 @@ int __must_check pci_enable_device_bars(
>  void pci_disable_device(struct pci_dev *dev);
>  void pci_set_master(struct pci_dev *dev);
>  #define HAVE_PCI_SET_MWI
> -int __must_check pci_set_mwi(struct pci_dev *dev);
> +int pci_set_mwi(struct pci_dev *dev);
>  void pci_clear_mwi(struct pci_dev *dev);
>  void pci_intx(struct pci_dev *dev, int enable);
>  int pci_set_dma_mask(struct pci_dev *dev, u64 mask);
