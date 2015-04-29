From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tcp: add TCP_CC_INFO socket option
Date: Wed, 29 Apr 2015 18:12:57 -0400 (EDT)
Message-ID: <20150429.181257.474967776040123413.davem@davemloft.net>
References: <1430263429-4069-1-git-send-email-edumazet@google.com>
	<1430263429-4069-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ycheng@google.com,
	ncardwell@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbbD2WM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:12:59 -0400
In-Reply-To: <1430263429-4069-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 28 Apr 2015 16:23:49 -0700

> Some Congestion Control modules can provide per flow information,
> but current way to get this information is to use netlink.
> 
> Like TCP_INFO, let's add TCP_CC_INFO so that applications can
> issue a getsockopt() if they have a socket file descriptor,
> instead of playing complex netlink games.
> 
> Sample usage would be :
> 
>   union tcp_cc_info info;
>   socklen_t len = sizeof(info);
> 
>   if (getsockopt(fd, SOL_TCP, TCP_CC_INFO, &info, &len) == -1)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
