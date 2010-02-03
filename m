From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Tue, 02 Feb 2010 17:27:10 -0800 (PST)
Message-ID: <20100202.172710.24662176.davem@davemloft.net>
References: <20100122141018D.fujita.tomonori@lab.ntt.co.jp>
	<20100121.223841.145479578.davem@davemloft.net>
	<20100203101817Z.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, alan@lxorguk.ukuu.org.uk,
	shemminger@linux-foundation.org, mbreuer@majjas.com,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mchan@broadcom.com, pcnet32@verizon.net, romieu@fr.zoreil.com,
	mcarlson@broadcom.com, James.Bottomley@suse.de
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51098
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753211Ab0BCB05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 20:26:57 -0500
In-Reply-To: <20100203101817Z.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 3 Feb 2010 10:18:39 +0900

> Can we safely assume that the arch implementations already round
> up/down to the safe boundary internally in this API (they should
> already)?

I can only speak for sparc64 and x86 directly and those are fine.

Any such improper implementations would fail with many common
ethernet drivers already.

> I don't like two DMA docs. I like to make pci_dma_* API obsolete. We
> have the generic DMA API with generic devices so we are always able to
> use the API (as you did with sbus_map_*). The majority arch
> implementations safely call the bus specific DMA functions via the
> generic DMA API. So there are not many things to do. We can just
> convert pci_dma_* to dma_* API slowly.
> 
> Opinions?

I have no problem with this.
