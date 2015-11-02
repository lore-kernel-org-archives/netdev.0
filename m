From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv6: fix crash on ICMPv6 redirects with
 prohibited/blackholed source
Date: Mon, 02 Nov 2015 16:30:45 -0500 (EST)
Message-ID: <20151102.163045.778833465670959622.davem@davemloft.net>
References: <7426eb388ade0f1ad800c408d7efa227d4f41408.1446423866.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mschiffer@universe-factory.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754296AbbKBVaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 16:30:46 -0500
In-Reply-To: <7426eb388ade0f1ad800c408d7efa227d4f41408.1446423866.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>
Date: Mon,  2 Nov 2015 01:24:38 +0100

> There are other error values besides ip6_null_entry that can be returned by
> ip6_route_redirect(): fib6_rule_action() can also result in
> ip6_blk_hole_entry and ip6_prohibit_entry if such ip rules are installed.
> 
> Only checking for ip6_null_entry in rt6_do_redirect() causes ip6_ins_rt()
> to be called with rt->rt6i_table == NULL in these cases, making the kernel
> crash.
> 
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>

Applied.
