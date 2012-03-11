From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] Pull request for 'davem-next.r8169' branch
Date: Sun, 11 Mar 2012 15:34:15 -0700 (PDT)
Message-ID: <20120311.153415.1118556368758210021.davem@davemloft.net>
References: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040Ab2CKWfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:35:24 -0400
In-Reply-To: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 10 Mar 2012 23:17:51 +0100

> Please pull from branch 'davem-next.r8169' in repository
> 
> git://violet.fr.zoreil.com/romieu/linux davem-next.r8169
> 
> to get the changes below.
> 
> This patchset tidies up the dependencies within the driver. I have not
> merged the patches to avoid confusing diff.

Pulled, thanks.

> I have a patchkit similar to the last patch in the series ("r8169: stop
> using net_device.{base_addr, irq}.") for some PCI only drivers. Depending
> on the driver, it contains either a few lines of changes (~20 drivers) or
> a complete conversion to __iomem + pci_iomap (4~6 drivers). Would it be
> appropriate to send a patch per driver for the latter and only a single
> patch for the former ?

Maybe a patch per-driver for this case.
