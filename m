From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] net/mlx4_en: allow setting number of rx rings for,
 RSS/TCP
Date: Mon, 21 Nov 2011 13:43:09 -0500 (EST)
Message-ID: <20111121.134309.970601561852715936.davem@davemloft.net>
References: <4ECA0F44.1080004@mellanox.co.il>
	<1321894651.2692.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, oren@mellanox.co.il, amirv@mellanox.co.il
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755252Ab1KUSnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 13:43:24 -0500
In-Reply-To: <1321894651.2692.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 21 Nov 2011 16:57:30 +0000

> On Mon, 2011-11-21 at 10:43 +0200, Yevgeny Petrilin wrote:
>> From: Amir Vadai <amirv@mellanox.co.il>
>> 
>> Make RSS TCP divert packets only to part of the rx rings, other could be
>> accessed by using flow steering or RFS acceleration
> [...]
> 
> The ethtool {get,set}_rxfh_indir operations are a standard and more
> flexible interface for configuring this.

Agreed, you should _NEVER_ add module options or private driver extensions
for such a common configuration setting.
