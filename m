From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/eth/ibmveth: Fixup retrieval of MAC address
Date: Sun, 05 May 2013 16:58:34 -0400 (EDT)
Message-ID: <20130505.165834.1729189703178834015.davem@davemloft.net>
References: <1367637541.4389.135.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	dwg@au1.ibm.com, bhutchings@solarflare.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab3EEU6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 May 2013 16:58:36 -0400
In-Reply-To: <1367637541.4389.135.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 04 May 2013 13:19:01 +1000

> Some ancient pHyp versions used to create a 8 bytes local-mac-address
> property in the device-tree instead of a 6 bytes one for veth.
> 
> The Linux driver code to deal with that is an insane hack which also
> happens to break with some choices of MAC addresses in qemu by testing
> for a bit in the address rather than just looking at the size of the
> property.
> 
> Sanitize this by doing the latter instead.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: <stable@vger.kernel.org>

Applied, thanks.
