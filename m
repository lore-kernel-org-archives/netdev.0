From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] inetpeer: add namespace support for
 inetpeer
Date: Wed, 06 Jun 2012 10:43:23 -0700 (PDT)
Message-ID: <20120606.104323.1698446129331745479.davem@davemloft.net>
References: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: serge.hallyn@canonical.com, ebiederm@xmission.com,
	herbert@gondor.apana.org.au, steffen.klassert@secunet.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab2FFRnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:43:24 -0400
In-Reply-To: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Tue, 5 Jun 2012 15:52:17 +0800

> now inetpeer doesn't support namespace,the information will
> be leaking across namespace.
> 
> this patch move the global vars v4_peers and v6_peers to
> netns_ipv4 and netns_ipv6 as a field peers.
> 
> add struct pernet_operations inetpeer_ops to initial pernet
> inetpeer data.
> 
> and change family_to_base and inet_getpeer to support namespace.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

As stated yesterday we have to move the inetpeer tree roots into
the FIB rule entries to fix other bugs, and that as a result will
transparently fix this problem too.

So I'm dropping these two patches and will work on the mentioned
approach to this fix.

Thanks.
