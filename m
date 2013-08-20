From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about ethernet/tundra/tsi108_eth.c
Date: Tue, 20 Aug 2013 12:35:20 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308201230150.2269@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:50381 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750986Ab3HTKfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 06:35:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver ethernet/tundra/tsi108_eth.c seems to be inconsistent about how
it shares buffers with the device.  In the open function (tsi108_open), it
uses virt_to_phys.  In the refill function (tsi108_refill_rx), it uses
dma_map_single.  However, there doesn't seem to be any dma_unmap_single
anywhere.

I see that this is not a very actively maintained driver, but I am
interested in the general question of how this works.

thanks,
julia
