From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet/jme: disable ASPM
Date: Mon, 08 Oct 2012 15:24:26 -0400 (EDT)
Message-ID: <20121008.152426.1524908667081347879.davem@davemloft.net>
References: <1349722956-14159-1-git-send-email-kevin.baradon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, mjg@redhat.com, netdev@vger.kernel.org
To: kevin.baradon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845Ab2JHTY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:24:29 -0400
In-Reply-To: <1349722956-14159-1-git-send-email-kevin.baradon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Baradon <kevin.baradon@gmail.com>
Date: Mon,  8 Oct 2012 21:02:36 +0200

> Based on patch from Matthew Garrett <mjg@redhat.com> (https://lkml.org/lkml/2011/11/11/168).
> 
> http://driveragent.com/archive/30421/7-0-14 indicates that ASPM is
> disabled on the 250 and 260. Duplicate for sanity.
> 
> Fixes random RX engine hangs I experienced with JMC250 on Clevo W270HU.
> 
> Signed-off-by: Kevin Baradon <kevin.baradon@gmail.com>

This should be a PCI quirk shouldn't it?

Also:

> +	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
> +		PCIE_LINK_STATE_CLKPM);

This is terrible formatting, you must line up the "PCIE_LINK_STATE_CLKPM" on
the second line with the very first column after the openning parenthesis
on the first line.
