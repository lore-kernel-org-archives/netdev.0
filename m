From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] net: SO_INCOMING_CPU support
Date: Tue, 11 Nov 2014 13:18:39 -0500 (EST)
Message-ID: <20141111.131839.327118129631165693.davem@davemloft.net>
References: <1415714068-21028-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, willemb@google.com,
	ycai@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbaKKSSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 13:18:42 -0500
In-Reply-To: <1415714068-21028-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 11 Nov 2014 05:54:26 -0800

> SO_INCOMING_CPU socket option (read by getsockopt()) provides
> an alternative to RPS/RFS for high performance servers using
> multi queues NIC.
> 
> TCP should use sk_mark_napi_id() for established sockets only.

Series applied, thanks Eric.
