From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Avoid unnecessary temporary addresses being generated
Date: Wed, 12 Mar 2014 15:47:56 -0400 (EDT)
Message-ID: <20140312.154756.2041500360476257988.davem@davemloft.net>
References: <5320B85B.4000100@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: heiner.kallweit@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbaCLTr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 15:47:57 -0400
In-Reply-To: <5320B85B.4000100@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiner Kallweit <heiner.kallweit@web.de>
Date: Wed, 12 Mar 2014 20:41:15 +0100

> tmp_prefered_lft is an offset to ifp->tstamp, not now. Therefore
> age needs to be added to the condition.
> 
> Age calculation in ipv6_create_tempaddr is different from the one
> in addrconf_verify and doesn't consider ADDRCONF_TIMER_FUZZ_MINUS.
> This can cause age in ipv6_create_tempaddr to be less than the one
> in addrconf_verify and therefore unnecessary temporary address to
> be generated.
> Use age calculation as in addrconf_modify to avoid this.
> 
> Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>

Please provide a proper subsystem prefix in your subject line,
after "[PATCH] ". In this case it would be "ipv6: ".
