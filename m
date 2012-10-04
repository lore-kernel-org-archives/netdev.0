From: David Miller <davem@davemloft.net>
Subject: Re: IPVS-DR problem with neigh lookup in 3.6
Date: Thu, 04 Oct 2012 02:58:08 -0400 (EDT)
Message-ID: <20121004.025808.2302904472507419433.davem@davemloft.net>
References: <alpine.LFD.2.00.1210040923010.1618@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755585Ab2JDG6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 02:58:12 -0400
In-Reply-To: <alpine.LFD.2.00.1210040923010.1618@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 4 Oct 2012 09:52:47 +0300 (EEST)

> 	Is it a good idea to keep rt_gateway always
> valid and to check RTCF_REDIRECTED where needed?

What exactly do you mean by this?  rt_gateway can only
be explicit nexthop or zero for local subnet.

It cannot take on any other value, otherwise routes are
not properly sharable.

> Because adding rt_dst does not look good, it will not
> help to callforward_do_filter too.

Adding rt_dst is not to be seriously considered.
