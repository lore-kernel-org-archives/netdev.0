From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: fix incorrect ipsec fragment
Date: Sun, 27 May 2012 01:12:16 -0400 (EDT)
Message-ID: <20120527.011216.1298417866757459701.davem@davemloft.net>
References: <1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1338031853-24938-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	lw@cn.fujitsu.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab2E0FMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2012 01:12:39 -0400
In-Reply-To: <1338031853-24938-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Sat, 26 May 2012 19:30:53 +0800

> Since commit ad0081e43a
> "ipv6: Fragment locally generated tunnel-mode IPSec6 packets as needed"
> the fragment of packets is incorrect.
> because tunnel mode needs IPsec headers and trailer for all fragments,
> while on transport mode it is sufficient to add the headers to the
> first fragment and the trailer to the last.
> 
> so modify mtu and maxfraglen base on ipsec mode and if fragment is first
> or last.
> 
> with my test,it work well(every fragment's size is the mtu)
> and does not trigger slow fragment path.
> 
> Changes from v1:
> 	though optimization, mtu_prev and maxfraglen_prev can be delete.
> 	replace xfrm mode codes with dst_entry's new frag DST_XFRM_TUNNEL.
> 	add fuction ip6_append_data_mtu to make codes clearer.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied, and queued up for -stable, thanks.
