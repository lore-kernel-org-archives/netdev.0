From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet/jme: disable ASPM
Date: Mon, 08 Oct 2012 15:39:53 -0400 (EDT)
Message-ID: <20121008.153953.2134806395029777705.davem@davemloft.net>
References: <1349722956-14159-1-git-send-email-kevin.baradon@gmail.com>
	<20121008.152426.1524908667081347879.davem@davemloft.net>
	<20121008193316.GA13684@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kevin.baradon@gmail.com, cooldavid@cooldavid.org,
	netdev@vger.kernel.org
To: mjg59@srcf.ucam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965Ab2JHTj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:39:56 -0400
In-Reply-To: <20121008193316.GA13684@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Garrett <mjg59@srcf.ucam.org>
Date: Mon, 8 Oct 2012 20:33:16 +0100

> On Mon, Oct 08, 2012 at 03:24:26PM -0400, David Miller wrote:
> 
>> This should be a PCI quirk shouldn't it?
> 
> No, it's a driver-level policy decision.

Then at a bare minimum this change should be using one of the ASPM
helpers provided by drivers/pci/pcie/aspm.c such as
pci_disable_link_state().
