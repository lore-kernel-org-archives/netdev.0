From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/ipv6: update flowi6_oif in
 ip6_dst_lookup_flow if not set
Date: Mon, 20 Jul 2015 12:59:53 -0700 (PDT)
Message-ID: <20150720.125953.222408356580015102.davem@davemloft.net>
References: <1436990186-31586-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbbGTT7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 15:59:54 -0400
In-Reply-To: <1436990186-31586-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Wed, 15 Jul 2015 21:56:26 +0200

> Newly created flows don't have flowi6_oif set (at least if the
> associated socket is not interface-bound). This leads to a mismatch in
> __xfrm6_selector_match() for policies which specify an interface in the
> selector (sel->ifindex != 0).
> 
> Backtracing shows this happens in code-paths originating from e.g.
> ip6_datagram_connect(), rawv6_sendmsg() or tcp_v6_connect(). (UDP was
> not tested for.)
> 
> In summary, this patch fixes policy matching on outgoing interface for
> locally generated packets.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied, thanks.
