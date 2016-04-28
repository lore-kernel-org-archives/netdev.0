From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: disable RSS when unsupported
Date: Thu, 28 Apr 2016 14:22:25 -0400 (EDT)
Message-ID: <20160428.142225.2060200700551666300.davem@davemloft.net>
References: <571E3CE4.6010808@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcooper@solarflare.com,
	linux-net-drivers@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbcD1SW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 14:22:26 -0400
In-Reply-To: <571E3CE4.6010808@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Mon, 25 Apr 2016 16:51:00 +0100

> From: Jon Cooper <jcooper@solarflare.com>
> 
> When certain firmware variants are selected (via the sfboot utility) the
> SFC7000 and SFC8000 series NICs don't support RSS. The driver still
> tries (and fails) to insert filters with the RSS flag, and the NIC fails
> to pass traffic.
> 
> When the firmware reports RSS_LIMITED suppress allocating a default RSS
> context. The absence of an RSS context is picked up in filter insertion
> and RSS flags are discarded.
> 
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied.
