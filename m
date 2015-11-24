From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] net: add driver for Netronome
 NFP4000/NFP6000 NIC VFs
Date: Tue, 24 Nov 2015 14:25:31 -0500 (EST)
Message-ID: <20151124.142531.1333743019199613941.davem@davemloft.net>
References: <20151030.192701.377276134095637949.davem@davemloft.net>
	<1448276697-2508-1-git-send-email-jakub.kicinski@netronome.com>
	<1448276697-2508-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbbKXTZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 14:25:33 -0500
In-Reply-To: <1448276697-2508-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 23 Nov 2015 11:04:57 +0000

> +#ifdef CONFIG_NFP_NET_DEBUG
> +#define DEBUG
> +#endif

Do not design ad-hoc debug logging facilities locally in your driver,
and instead use the existing tree wide facilities as they were designed
to be used so that any user can get debugging logs simply by turning it
on at run time rather than having the change magic config options in
their kernel.
