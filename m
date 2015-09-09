From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] net: ipv6: use common fib_default_rule_pref
Date: Tue, 08 Sep 2015 22:37:05 -0700 (PDT)
Message-ID: <20150908.223705.1178974104676916256.davem@davemloft.net>
References: <20150905.220040.768580139044156666.davem@davemloft.net>
	<1441534858-6452-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbbIIFhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 01:37:06 -0400
In-Reply-To: <1441534858-6452-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Sun,  6 Sep 2015 12:20:58 +0200

> This switches IPv6 policy routing to use the shared
> fib_default_rule_pref() function of IPv4 and DECnet. It is also used in
> multicast routing for IPv4 as well as IPv6.
> 
> The motivation for this patch is a complaint about iproute2 behaving
> inconsistent between IPv4 and IPv6 when adding policy rules: Formerly,
> IPv6 rules were assigned a fixed priority of 0x3FFF whereas for IPv4 the
> assigned priority value was decreased with each rule added.
> 
> Since then all users of the default_pref field have been converted to
> assign the generic function fib_default_rule_pref(), fib_nl_newrule()
> may just use it directly instead. Therefore get rid of the function
> pointer altogether and make fib_default_rule_pref() static, as it's not
> used outside fib_rules.c anymore.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v1:
> - Folded together with API change and adjusted commit message accordingly.

Applied, thanks.
