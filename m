From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] gianfar: Tx timeout issue
Date: Mon, 10 Mar 2014 13:18:27 -0400 (EDT)
Message-ID: <20140310.131827.672807362272151307.davem@davemloft.net>
References: <1394196166-24932-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbaCJRSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:18:33 -0400
In-Reply-To: <1394196166-24932-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 7 Mar 2014 14:42:44 +0200

> There's an older Tx timeout issue showing up on etsec2 devices
> with 2 CPUs.  I pinned this issue down to processing overhead
> incurred by supporting multiple Tx/Rx rings, as explained in
> the 2nd patch below.  But before this, there's also a concurency
> issue leading to Rx/Tx spurrious interrupts, addressed by the
> 'Tx NAPI' patch below.
> The Tx timeout can be triggered with multiple Tx flows,
> 'iperf -c -N 8' commands, on a 2 CPUs etsec2 based (P1020) board.

Series applied, thanks.
