From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v5 net 0/3] ipv6: Reduce the number of
 fib6_lookup() calls from ip6_pol_route()
Date: Fri, 24 Oct 2014 00:15:50 -0400 (EDT)
Message-ID: <20141024.001550.1808591527768047773.davem@davemloft.net>
References: <1413837765-5446-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755145AbaJXEPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 00:15:52 -0400
In-Reply-To: <1413837765-5446-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 20 Oct 2014 13:42:42 -0700

> This patch set is trying to reduce the number of fib6_lookup()
> calls from ip6_pol_route().
> 
> I have adapted davem's udpflooda and kbench_mod test
> (https://git.kernel.org/pub/scm/linux/kernel/git/davem/net_test_tools.git) to
> support IPv6 and here is the result:

Series applied, thanks.

Can you cook up some clean patches against the net_test_tools repo so
that people can use it for both ipv4 and ipv6 route lookup measurements?

Thanks.
