From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: ipv4: fix an use after free in __udp4_lib_rcv()
Date: Tue, 10 Dec 2013 22:59:06 -0500 (EST)
Message-ID: <20131210.225906.1861492646485883383.davem@davemloft.net>
References: <20131211003948.GA18825@redhat.com>
	<1386723287.30495.352.camel@edumazet-glaptop2.roam.corp.google.com>
	<1386727643.30495.363.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, sbohrer@rgmadvisors.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab3LKD7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 22:59:08 -0500
In-Reply-To: <1386727643.30495.363.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Dec 2013 18:07:23 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dave Jones reported a use after free in UDP stack :
 ...
> We need to keep a reference on the socket, by using skb_steal_sock()
> at the right place.
> 
> Note that another patch is needed to fix a race in
> udp_sk_rx_dst_set(), as we hold no lock protecting the dst.
> 
> Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>

Applied, thanks Eric.
