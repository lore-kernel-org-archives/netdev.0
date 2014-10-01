From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: fix potential NULL pointer
 dereference
Date: Wed, 01 Oct 2014 15:26:37 -0400 (EDT)
Message-ID: <20141001.152637.1685190725218204898.davem@davemloft.net>
References: <542C1837.6090009@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbaJAT0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:26:39 -0400
In-Reply-To: <542C1837.6090009@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Wed, 01 Oct 2014 11:05:27 -0400

> One of the error cases for vnet_start_xmit()'s "out_dropped" label
> is port == NULL, so only mess with port->clean_timer when port is not NULL.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Applied, thanks David.
