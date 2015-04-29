From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: prepare CC get_info() access from
 getsockopt()
Date: Wed, 29 Apr 2015 18:12:52 -0400 (EDT)
Message-ID: <20150429.181252.2106091176943411796.davem@davemloft.net>
References: <1430263429-4069-1-git-send-email-edumazet@google.com>
	<1430263429-4069-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ycheng@google.com,
	ncardwell@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbbD2WMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:12:53 -0400
In-Reply-To: <1430263429-4069-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 28 Apr 2015 16:23:48 -0700

> We would like that optional info provided by Congestion Control
> modules using netlink can also be read using getsockopt()
> 
> This patch changes get_info() to put this information in a buffer,
> instead of skb, like tcp_get_info(), so that following patch
> can reuse this common infrastructure.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
