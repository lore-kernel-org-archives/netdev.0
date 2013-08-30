From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fec: fix time stamping logic after napi
 conversion
Date: Fri, 30 Aug 2013 18:02:02 -0400 (EDT)
Message-ID: <20130830.180202.2159152463367648290.davem@davemloft.net>
References: <22741489040b99d0c1025dcbf993fd5cfd859123.1377887138.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frank.Li@freescale.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571Ab3H3WCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 18:02:04 -0400
In-Reply-To: <22741489040b99d0c1025dcbf993fd5cfd859123.1377887138.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 30 Aug 2013 20:28:10 +0200

> Commit dc975382 "net: fec: add napi support to improve proformance"
> converted the fec driver to the napi model. However, that commit
> forgot to remove the call to skb_defer_rx_timestamp which is only
> needed in non-napi drivers.
> 
> (The function napi_gro_receive eventually calls netif_receive_skb,
> which in turn calls skb_defer_rx_timestamp.)
> 
> This patch should also be applied to the 3.9 and 3.10 kernels.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied and queued up for -stable, thanks!
