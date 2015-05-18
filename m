From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/6] tcp: better handling of memory pressure
Date: Sun, 17 May 2015 22:46:14 -0400 (EDT)
Message-ID: <20150517.224614.172324913790818801.davem@davemloft.net>
References: <1431718770-3815-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbaron@akamai.com, ncardwell@google.com,
	ycheng@google.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbbERCqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 22:46:17 -0400
In-Reply-To: <1431718770-3815-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 15 May 2015 12:39:24 -0700

> When testing commit 790ba4566c1a ("tcp: set SOCK_NOSPACE under memory
> pressure") using edge triggered epoll applications, I found various
> issues under memory pressure and thousands of active sockets.
> 
> This patch series is a first round to solve these issues, in send
> and receive paths. There are probably other fixes needed, but
> with this series, my tests now all succeed.
> 
> v2: fix typo in "allow one skb to be received per socket under memory pressure",
> as spotted by Jason Baron.

Looks good, series applied, thanks Eric.
