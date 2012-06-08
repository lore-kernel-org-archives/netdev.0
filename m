From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] inetpeer: add namespace support for
 inetpeer
Date: Fri, 08 Jun 2012 14:27:42 -0700 (PDT)
Message-ID: <20120608.142742.1627858906014237271.davem@davemloft.net>
References: <1339137683-19217-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, steffen.klassert@secunet.com,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651Ab2FHV1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 17:27:47 -0400
In-Reply-To: <1339137683-19217-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Fri,  8 Jun 2012 14:41:23 +0800

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

Applied.
