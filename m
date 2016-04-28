From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/3] tcp: Make use of MSG_EOR in tcp_sendmsg
Date: Thu, 28 Apr 2016 16:14:45 -0400 (EDT)
Message-ID: <20160428.161445.2283870295645734966.davem@davemloft.net>
References: <1461620690-1081063-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
	soheil@google.com, willemb@google.com, ycheng@google.com,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbcD1UOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:14:48 -0400
In-Reply-To: <1461620690-1081063-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 25 Apr 2016 14:44:47 -0700

 ...
> One potential use case is to use MSG_EOR with
> SOF_TIMESTAMPING_TX_ACK to get a more accurate
> TCP ack timestamping on application protocol with
> multiple outgoing response messages (e.g. HTTP2).
> 
> One of our use case is at the webserver.  The webserver tracks
> the HTTP2 response latency by measuring when the webserver sends
> the first byte to the socket till the TCP ACK of the last byte
> is received.  In the cases where we don't have client side
> measurement, measuring from the server side is the only option.
> In the cases we have the client side measurement, the server side
> data can also be used to justify/cross-check-with the client
> side data.

Looks good, series applied, thanks!
