From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "ipv6: Allow for partial checksums on
 non-ufo packets"
Date: Sun, 10 May 2015 19:53:10 -0400 (EDT)
Message-ID: <20150510.195310.1793091517182760839.davem@davemloft.net>
References: <2088438.42IY8hjjd5@h2o.as.studentenwerk.mhn.de>
	<1431122268.22756.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<1431123765.22756.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@stwm.de, vyasevich@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbbEJXxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 19:53:12 -0400
In-Reply-To: <1431123765.22756.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 May 2015 15:22:45 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Wolfgang Walter reported crashes using traceroute6, root caused to this
> commit.
> 
> UDP packets can be sent from RAW sockets.
> 
> Note that the faulty commit addressed a non problem, as normal
> UDP v6 packets use udp_v6_send_skb() which correctly setup
> CHECKSUM_PARTIAL properly if device has the correct feature.
> 
> It seems not worth trying to 'fix' the raw path.
> 
> Fixes: 32dce968dd98 ("ipv6: Allow for partial checksums on non-ufo packets")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Wolfgang Walter <linux@stwm.de>

Vlad, please review this.

Thanks.
