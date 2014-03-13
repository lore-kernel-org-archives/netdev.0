From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: Avoid unnecessary temporary addresses being
 generated
Date: Thu, 13 Mar 2014 15:49:46 -0400 (EDT)
Message-ID: <20140313.154946.2142259577860056292.davem@davemloft.net>
References: <5320CDEF.2020802@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: heiner.kallweit@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755082AbaCMTts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:49:48 -0400
In-Reply-To: <5320CDEF.2020802@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiner Kallweit <heiner.kallweit@web.de>
Date: Wed, 12 Mar 2014 22:13:19 +0100

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

Looks good, applied, thank you.
