From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 10/21] r8169: merge with version 6.001.00 of Realtek's
	r8169 driver
Date: Fri, 29 Jun 2007 13:35:35 -0700
Message-ID: <1183149335.2642.10.camel@laptopd505.fenrus.org>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
	 <20070629202510.GL3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58283 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbXF2Uhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 16:37:34 -0400
In-Reply-To: <20070629202510.GL3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);

can you create a pci_set_latency_timer() for this please?

> +
> +	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
> +		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 0x08);

and something for this as well?

