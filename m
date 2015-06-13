From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] flow_dissector: fix ipv6 dst, hop-by-hop and
 routing ext hdrs
Date: Fri, 12 Jun 2015 21:59:01 -0700 (PDT)
Message-ID: <20150612.215901.1746619163064507549.davem@davemloft.net>
References: <1434161476.27504.105.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150613021534.GA9942@Alexeis-MacBook-Pro.local>
	<1434162692.27504.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tom@herbertland.com,
	edumazet@google.com, netdev@vger.kernel.org,
	dan.carpenter@oracle.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbFME7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 00:59:05 -0400
In-Reply-To: <1434162692.27504.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Jun 2015 19:31:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> __skb_header_pointer() returns a pointer that must be checked.
> 
> Fixes infinite loop reported by Alexei, and add __must_check to
> catch these errors earlier.
> 
> Fixes: 6a74fcf426f5 ("flow_dissector: add support for dst, hop-by-hop and routing ext hdrs")
> Reported-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Tested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
