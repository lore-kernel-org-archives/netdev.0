From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4] e100: add non-MII PHY support
Date: Thu, 11 Jun 2009 02:34:51 -0700 (PDT)
Message-ID: <20090611.023451.144889336.davem@davemloft.net>
References: <200906101955.n5AJt4pV008252@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andim2@users.sourceforge.net,
	andi@lisas.de, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, peter.p.waskiewicz.jr@intel.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758852AbZFKJet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:34:49 -0400
In-Reply-To: <200906101955.n5AJt4pV008252@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 10 Jun 2009 12:55:04 -0700

> From: Andreas Mohr <andim2@users.sourceforge.net>
> 
> Restore support for cards with MII-lacking PHYs as compared to removed
> pre-2.6.29 eepro100 driver: use full low-level MII I/O access abstraction
> by providing clean PHY-specific mdio_ctrl() functions for either standard
> MII-compliant cards, slightly special ones or non-MII PHY ones.
> 
> We now have another netdev_priv member for mdio_ctrl(), thus we have some
> array indirection, but we save some additional opcodes for specific
> phy_82552_v handling in the common case.
> 
> [akpm@linux-foundation.org: cleanups]
> Signed-off-by: Andreas Mohr <andi@lisas.de>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
