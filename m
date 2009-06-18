From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: fix dma api mismatches
Date: Thu, 18 Jun 2009 12:02:21 -0700 (PDT)
Message-ID: <20090618.120221.92059096.davem@davemloft.net>
References: <20090618.004642.31377117.davem@davemloft.net>
	<1FC56210173BB445BD77F608D6FB8D03036AA43501@HQMAIL03.nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: AAbdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39060
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752638AbZFRTCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 15:02:18 -0400
In-Reply-To: <1FC56210173BB445BD77F608D6FB8D03036AA43501@HQMAIL03.nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <AAbdulla@nvidia.com>
Date: Thu, 18 Jun 2009 10:33:43 -0700

> Doing a quick indentifier search on 2.6.17 shows that
> pci_unmap_page() just calls pci_unmap_single().

You should check more recent kernels.

> I think this will just add extra clutter. We can just add a comment
> in the code instead that they perform the same thing.

It causes log messages with the DMA API debugging layer that checks
whether you match up the calls correctly.

