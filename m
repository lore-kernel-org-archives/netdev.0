From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] Ethernet driver for the WIZnet W5300 chip
Date: Tue, 27 Mar 2012 22:35:45 -0400 (EDT)
Message-ID: <20120327.223545.1996930432677091672.davem@davemloft.net>
References: <1332149037-12025-1-git-send-email-msink@permonline.ru>
	<1332752876-1650-1-git-send-email-msink@permonline.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, eric.dumazet@gmail.com
To: msink@permonline.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757454Ab2C1CgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:36:04 -0400
In-Reply-To: <1332752876-1650-1-git-send-email-msink@permonline.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Sinkovsky <msink@permonline.ru>
Date: Mon, 26 Mar 2012 15:07:56 +0600

> +/*
> + * Frame size is hardwired to 1514 bytes (including header),
> + *  => MTU for 802.1Q frames must be set to 1500-4 = 1496
> + */
> +#define W5300_HARD_MTU		1500

I've told you that you must set the VLAN challenged feature flag
(NETIF_F_VLAN_CHALLENGED) for devices which have this restriction.

Just set that, and remove this comment, since the feature bit setting
documents this restriction fully and perfectly.
