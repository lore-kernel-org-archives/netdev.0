From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: find correct route for socket which is not bound
 (v2)
Date: Thu, 24 Sep 2015 14:22:28 -0700 (PDT)
Message-ID: <20150924.142228.132445616196971304.davem@davemloft.net>
References: <1442822409-9799-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wen.gang.wang@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbbIXVW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 17:22:29 -0400
In-Reply-To: <1442822409-9799-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wengang Wang <wen.gang.wang@oracle.com>
Date: Mon, 21 Sep 2015 16:00:09 +0800

> This is the v2, comparing the v1, the changes is:
>  * for loopback outbound device, it continue skipping cached route;
>    for others, it goes through the cached route.

There are many things I want you to clean up in your commit message.

> For multi-cast, we should find valid route(thus get the meaniful pmtu) for
> the package on the socket which is not bound to a device(sk_bound_dev_if
> being 0) too.

Please use the term "packet" rather than "package".  Gifts you receive
from a friend might be in a "package", but data is sent onto a network
inside of "packets".

> A problem is hit that all multi-cast packages dropped by kernel(from sender

"multicast" is a single word.

> host). The lower layer is IPoIB with MTU being 7000. And I was sending 4096
> length multi-cast  package. In side IPoIB the first send is dropped because

"Inside" is one word.
