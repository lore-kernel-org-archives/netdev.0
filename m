From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Fri, 11 Apr 2014 12:26:53 +0900
Message-ID: <534760FD.9050306@linux-ipv6.org>
References: <5345A2B3.7040602@gmail.com>		 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>		 <20140409223546.GH27255@order.stressinduktion.org>		 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>		 <20140410235459.GK27255@order.stressinduktion.org>		 <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>	 <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>	 <534753D4.6070600@linux-ipv6.org> <1397186427.16584.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:59451 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751938AbaDKD0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 23:26:55 -0400
In-Reply-To: <1397186427.16584.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
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
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
