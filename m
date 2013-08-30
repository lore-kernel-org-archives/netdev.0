From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Remove needless check of return value
Date: Thu, 29 Aug 2013 21:36:27 -0400 (EDT)
Message-ID: <20130829.213627.1536495569096415942.davem@davemloft.net>
References: <1377825558-8800-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab3H3Bgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 21:36:31 -0400
In-Reply-To: <1377825558-8800-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Thu, 29 Aug 2013 18:19:18 -0700

> After commit 0c24604b (tcp: implement RFC 5961 4.2), tcp_rcv_established() only
> returns 0 since we no longer send RSTs in response to SYNs. We can remove the
> check on the return value.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Always returning the same value is the same as returning no value at all.

Make tcp_rcv_established() return void please.
