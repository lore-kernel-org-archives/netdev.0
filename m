From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] gianfar: Restore promisc mode on
 gfar_init_mac()
Date: Wed, 23 Jan 2013 13:54:43 -0500 (EST)
Message-ID: <20130123.135443.478554694714510693.davem@davemloft.net>
References: <1358936316-8195-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cedric.voncken@acksys.fr
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab3AWSyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 13:54:46 -0500
In-Reply-To: <1358936316-8195-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 23 Jan 2013 12:18:36 +0200

> Reactivate promiscuous mode in H/W upon gfar_init_mac(), if the
> net dev requires it (IFF_PROMISC flag set).
> This way the promisc mode is preserved accross device reset conditions
> like tx timeout, device restore, a.s.o.
> 
> Signed-off-by: Voncken C Acksys <cedric.voncken@acksys.fr>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks.
