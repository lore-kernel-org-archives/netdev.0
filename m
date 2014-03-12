From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gianfar: Fix multi-queue support checks
 @probe()
Date: Wed, 12 Mar 2014 00:48:14 -0400 (EDT)
Message-ID: <20140312.004814.442682826470309335.davem@davemloft.net>
References: <1394553684-12061-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbaCLE6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 00:58:25 -0400
In-Reply-To: <1394553684-12061-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Tue, 11 Mar 2014 18:01:24 +0200

> priv is not instantiated at gfar_of_init() time, when
> parsing the DT for info on supported HW queues.  Before
> the netdev can be allocated, the number of supported
> queues must be known.  Because the number of supported
> queues depends on device type, move the compatibility
> checks before netdev allocation.  Local vars are used
> to hold the operation mode info before netdev allocation.
> This fixes the null accesses for priv->.., in gfar_of_init.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thank you.
