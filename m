From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net 0/2] ipv6: Avoid restarting fib6_lookup() for
 RTF_CACHE hit
Date: Mon, 06 Oct 2014 17:10:43 -0400 (EDT)
Message-ID: <20141006.171043.1460088080687970.davem@davemloft.net>
References: <1412374332-26657-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaJFVKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:10:48 -0400
In-Reply-To: <1412374332-26657-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 3 Oct 2014 15:12:10 -0700

> I am trying to understand why there is a need to restart fib6_lookup() after
> getting rt with RTF_CACHE.
> 
> I have adapted the davem's udpflood test
> (https://git.kernel.org/pub/scm/linux/kernel/git/davem/net_test_tools.git) to
> support IPv6 and here is the result:
> 
> #root > time ./udpflood -l 20000000 -c 250 2401:db00:face:face::2
> 
> Before:
> real    0m33.224s
> user    0m2.941s
> sys     0m30.232s
> 
> After:
> real    0m31.517s
> user    0m2.938s
> sys     0m28.536s

If you are serious about seeing these patches integrated, you must
freshly repost this series and provide a proper "Signed-off-by: " tag
for yourself in the commit messages.
