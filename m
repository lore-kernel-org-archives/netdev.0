From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: flush nd cache on IFF_NOARP change
Date: Wed, 29 Jul 2015 23:01:53 -0700 (PDT)
Message-ID: <20150729.230153.72255655678954107.davem@davemloft.net>
References: <1438161351.20182.73.camel@edumazet-glaptop2.roam.corp.google.com>
	<1438162343.20182.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<1438164101.20182.83.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, valas@google.com, willemb@google.com,
	mariofanelli@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbG3GBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 02:01:54 -0400
In-Reply-To: <1438164101.20182.83.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Jul 2015 12:01:41 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch is the IPv6 equivalent of commit
> 6c8b4e3ff81b ("arp: flush arp cache on IFF_NOARP change") 
> 
> Without it, we keep buggy neighbours in the cache, with destination
> MAC address equal to our own MAC address.
> 
> Tested:
>  tcpdump -i eth0 -s 0 ip6 -n -e &
>  ip link set dev eth0 arp off
>  ping6 remote   // sends buggy frames
>  ip link set dev eth0 arp on
>  ping6 remote   // should work once kernel is patched
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Mario Fanelli <mariofanelli@google.com>

Applied, thanks Eric.
