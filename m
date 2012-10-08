From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/6] ipv4: Changes for rt_gateway
Date: Mon, 08 Oct 2012 17:43:10 -0400 (EDT)
Message-ID: <20121008.174310.138554100330578332.davem@davemloft.net>
References: <1349732480-19978-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937Ab2JHVnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 17:43:16 -0400
In-Reply-To: <1349732480-19978-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue,  9 Oct 2012 00:41:14 +0300

> 	This patchset fixes some problems for the routing caused
> by the new rt_gateway semantics. What started as a fix for
> IPVS-DR ended as fixes for more problems. To solve the IPVS
> problem I decided to name the flag FLOWI_FLAG_KNOWN_NH, so that
> we can even get route cached in FNHE or FIB NH.
> 
> 	Different flag FLOWI_FLAG_RT_NOCACHE could be equally good
> for IPVS, we again would be able to use data from fnhe but working
> with cached routes should be preferred. If there is no FNHE, the
> common case is IPVS to get uncached route, of course, IPVS caches
> it itself.
> 
> 	Patches 1-3 are fixes not related to IPVS problem,
> 4 and 5 add code that will be used by IPVS in patch 6.

This series looks great, applied, thanks Julian.
