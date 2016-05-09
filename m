From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: refactor struct tcp_skb_cb
Date: Mon, 09 May 2016 00:06:24 -0400 (EDT)
Message-ID: <20160509.000624.2258641144075621164.davem@davemloft.net>
References: <1462592135-1905403-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbcEIEGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 00:06:31 -0400
In-Reply-To: <1462592135-1905403-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Fri, 6 May 2016 20:35:35 -0700

> Refactor tcp_skb_cb to create two overlaping areas to store
> state for incoming or outgoing skbs based on comments by
> Neal Cardwell to tcp_nv patch:
> 
>    AFAICT this patch would not require an increase in the size of
>    sk_buff cb[] if it were to take advantage of the fact that the
>    tcp_skb_cb header.h4 and header.h6 fields are only used in the packet
>    reception code path, and this in_flight field is only used on the
>    transmit side.
> 
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Applied.
