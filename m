From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv6: more places need LOOPBACK_IFINDEX for
 flowi6_iif
Date: Mon, 28 Apr 2014 14:47:14 -0400 (EDT)
Message-ID: <20140428.144714.751976236360193141.davem@davemloft.net>
References: <1398671516-8842-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756493AbaD1TXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:23:14 -0400
In-Reply-To: <1398671516-8842-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 28 Apr 2014 10:51:56 +0300

> To properly match iif in ip rules we have to provide
> LOOPBACK_IFINDEX in flowi6_iif, not 0. Some ip6mr_fib_lookup
> and fib6_rule_lookup callers need such fix.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks.
