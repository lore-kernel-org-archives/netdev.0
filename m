From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] tcp: add tcpi_bytes_received to
 tcp_info
Date: Wed, 29 Apr 2015 18:12:44 -0400 (EDT)
Message-ID: <20150429.181244.299663707973224834.davem@davemloft.net>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
	<1430260098-14127-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ycheng@google.com,
	mattmathis@google.com, salo@google.com, kafai@fb.com,
	rapier@psc.edu
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbbD2WMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:12:46 -0400
In-Reply-To: <1430260098-14127-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 28 Apr 2015 15:28:18 -0700

> This patch tracks total number of payload bytes received on a TCP socket.
> This is the sum of all changes done to tp->rcv_nxt
> 
> RFC4898 named this : tcpEStatsAppHCThruOctetsReceived
> 
> This is a 64bit field, and can be fetched both from TCP_INFO
> getsockopt() if one has a handle on a TCP socket, or from inet_diag
> netlink facility (iproute2/ss patch will follow)
> 
> Note that tp->bytes_received was placed near tp->rcv_nxt for
> best data locality and minimal performance impact.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
