From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv6: Limit mtu to 65575 bytes
Date: Fri, 11 Apr 2014 16:48:48 -0400 (EDT)
Message-ID: <20140411.164848.983714986536717393.davem@davemloft.net>
References: <534753D4.6070600@linux-ipv6.org>
	<1397186427.16584.86.camel@edumazet-glaptop2.roam.corp.google.com>
	<1397190216.16584.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
	f.wellenreiter@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbaDKUsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 16:48:50 -0400
In-Reply-To: <1397190216.16584.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Apr 2014 21:23:36 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Francois reported that setting big mtu on loopback device could prevent
> tcp sessions making progress.
> 
> We do not support (yet ?) IPv6 Jumbograms and cook corrupted packets.
> 
> We must limit the IPv6 MTU to (65535 + 40) bytes in theory.
> 
> Tested:
> 
> ifconfig lo mtu 70000
> netperf -H ::1
> 
> Before patch : Throughput :   0.05 Mbits
> 
> After patch : Throughput : 35484 Mbits
> 
> Reported-by: Francois WELLENREITER <f.wellenreiter@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied and queued up for -stable, thanks Eric.
