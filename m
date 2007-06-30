From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 10/21] r8169: merge with version 6.001.00 of Realtek's r8169 driver
Date: Sat, 30 Jun 2007 11:41:38 +0200
Message-ID: <20070630094138.GB13042@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com> <20070629202510.GL3240@electric-eye.fr.zoreil.com> <1183149335.2642.10.camel@laptopd505.fenrus.org> <46857068.4050803@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37198 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844AbXF3Jo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 05:44:29 -0400
Content-Disposition: inline
In-Reply-To: <46857068.4050803@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
> Arjan van de Ven wrote:
> >>+	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
> >
> >can you create a pci_set_latency_timer() for this please?
[...]
> >>+	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
> >>+		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 
> >>0x08);
> >
> >and something for this as well?
> 
> Why?  Nothing here seems generic to me.

I.e. no need for pci_set_latency_timer(struct pci_dev *dev, u8 latency)
neither pci_set_cache_line_size(struct pci_dev *dev, u8 size) ?

-- 
Ueimor
