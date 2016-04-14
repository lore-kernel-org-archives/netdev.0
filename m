From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6, token: allow for clearing the current
 device token
Date: Wed, 13 Apr 2016 22:43:28 -0400 (EDT)
Message-ID: <20160413.224328.1801760395837378312.davem@davemloft.net>
References: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, robbat2@gentoo.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbcDNCnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 22:43:35 -0400
In-Reply-To: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  8 Apr 2016 15:55:00 +0200

> The original tokenized iid support implemented via f53adae4eae5 ("net: ipv6:
> add tokenized interface identifier support") didn't allow for clearing a
> device token as it was intended that this addressing mode was the only one
> active for globally scoped IPv6 addresses. Later we relaxed that restriction
> via 617fe29d45bd ("net: ipv6: only invalidate previously tokenized addresses"),
> and we should also allow for clearing tokens as there's no good reason why
> it shouldn't be allowed.
> 
> Fixes: 617fe29d45bd ("net: ipv6: only invalidate previously tokenized addresses")
> Reported-by: Robin H. Johnson <robbat2@gentoo.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied to net-next, thanks.
