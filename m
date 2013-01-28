From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] r8169: fix vlan tag read ordering.
Date: Sun, 27 Jan 2013 19:29:19 -0500 (EST)
Message-ID: <20130127.192919.269296979659118968.davem@davemloft.net>
References: <20130124233006.GA7511@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com, timo.teras@iki.fi
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab3A1A3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 19:29:20 -0500
In-Reply-To: <20130124233006.GA7511@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 25 Jan 2013 00:30:06 +0100

> Control of receive descriptor must not be returned to ethernet chipset
> before vlan tag processing is done.
> 
> VLAN tag receive word is now reset both in normal and error path.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Spotted-by: Timo Teras <timo.teras@iki.fi>
> Cc: Hayes Wang <hayeswang@realtek.com>

Applied.
