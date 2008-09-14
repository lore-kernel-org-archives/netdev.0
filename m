From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch v1.2.34] WAN: merge driver retina
Date: Sat, 13 Sep 2008 20:16:43 -0400
Message-ID: <48CC57EB.9010500@pobox.com>
References: <ca0148c30807032339o4182fbadq370f709a28861053@mail.gmail.com>	 <489A96B2.4030903@pobox.com>	 <ca0148c30808072334w5d2d8216s37152621b4aa8ebf@mail.gmail.com> <ca0148c30808120246w5c2eca09u3bfa08e3ea40cfe4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47523 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492AbYINAQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 20:16:47 -0400
In-Reply-To: <ca0148c30808120246w5c2eca09u3bfa08e3ea40cfe4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Linnanvuori wrote:
> From: Matti Linnanvuori <matti.linnanvuori@ascom.com>
> 
> Retina G.703 and G.SHDSL PCI card driver.
> 
> Signed-off-by: Matti Linnanvuori <matti.linnanvuori@ascom.com>
> 
> ---
> 
> I am sending a patch against 'retina' branch of jgarzik/netdev-2.6.git.
> This patch fixes the netif_tx_unlock bug in the previous patch.

Changes look good, but do not apply to the 'retina' branch.  Also, the 
virt_to_bus/virt_to_phys stuff should be replaced with DMA mapping API 
usage.


