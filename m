From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-timestamp: cumulative tcp timestamping
 fixes
Date: Wed, 06 Aug 2014 14:09:23 -0700 (PDT)
Message-ID: <20140806.140923.864467090635818084.davem@davemloft.net>
References: <1407352184-26058-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbaHFVJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 17:09:24 -0400
In-Reply-To: <1407352184-26058-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed,  6 Aug 2014 15:09:44 -0400

> A set of small fixes pointed out just after the merge:
> - make tcp_tx_timestamp static
> - make tcp_gso_tstamp static
> - use before() to compare TCP seqno, instead of cast to u64
> - add tstamp to tx_flags in GSO, instead of overwrite tx_flags
> - record skb_shinfo(skb)->tskey for all timestamps, also HW.
> - optimization in tcp_tx_timestamp:
>   call sock_tx_timestamp only if a tstamp option is set.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Fixes: 4ed2d765dfac ("net-timestamp: TCP timestamping")

Applied, thank you.
