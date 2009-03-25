From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/10] Neterion: New driver: pci_ids
Date: Wed, 25 Mar 2009 01:06:03 -0700 (PDT)
Message-ID: <20090325.010603.211433093.davem@davemloft.net>
References: <1237968756.1655.263.camel@flash>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34977
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752954AbZCYIGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 04:06:15 -0400
In-Reply-To: <1237968756.1655.263.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ramkrishna Vepa <ram.vepa@neterion.com>
Date: 25 Mar 2009 00:12:36 -0800

> - Update device ID of X3100 Series 10GbE PCIe I/O Virtualized Server Adapter.
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -Nurp patch_2/include/linux/pci_ids.h patch_3/include/linux/pci_ids.h
> --- patch_2/include/linux/pci_ids.h	2009-03-23 09:17:41.000000000 -0700
> +++ patch_3/include/linux/pci_ids.h	2009-03-23 09:17:41.000000000 -0700
> @@ -2209,6 +2209,8 @@

This file is deprecated.  If your driver is the only place that
needs this PCI ID just use the constant there.
