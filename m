From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix a bad cast in ip6_dst_lookup_tail()
Date: Fri, 06 Jul 2012 00:24:58 -0700 (PDT)
Message-ID: <20120706.002458.1826403917382395625.davem@davemloft.net>
References: <1341557587.3265.107.camel@edumazet-glaptop>
	<20120706.000341.755169655502291970.davem@davemloft.net>
	<1341559145.3265.141.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab2GFHep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 03:34:45 -0400
In-Reply-To: <1341559145.3265.141.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jul 2012 09:19:05 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Fix a bug in ip6_dst_lookup_tail(), where typeof(dst) is 
> "struct dst_entry **", not "struct dst_entry *"
> 
> Reported-by: Fengguang Wu <wfg@linux.intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
