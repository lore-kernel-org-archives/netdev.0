From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: tcp: remove per net tcp_sock
Date: Sun, 22 Jul 2012 12:08:41 -0700 (PDT)
Message-ID: <20120722.120841.1622431474480383380.davem@davemloft.net>
References: <1342719243.2626.4571.camel@edumazet-glaptop>
	<20120721170035.be1bb3aff663ecf9e81028e2@gmail.com>
	<1342859331.2626.8385.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shimoda.hiroaki@gmail.com, netdev@vger.kernel.org,
	therbert@google.com, wsommerfeld@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362Ab2GVTIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:08:44 -0400
In-Reply-To: <1342859331.2626.8385.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 21 Jul 2012 10:28:51 +0200

> [PATCH net-next] ipv4: tcp: set unicast_sock uc_ttl to -1
> 
> Set unicast_sock uc_ttl to -1 so that we select the right ttl,
> instead of sending packets with a 0 ttl.
> 
> Bug added in commit be9f4a44e7d4 (ipv4: tcp: remove per net tcp_sock)
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

APplied, thanks everyone.
