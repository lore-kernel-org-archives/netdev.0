From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] ipv6: Limit mtu to 65575 bytes
Date: Fri, 11 Apr 2014 15:22:07 +0200
Message-ID: <20140411132207.GO27255@order.stressinduktion.org>
References: <5345A2B3.7040602@gmail.com> <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com> <20140409223546.GH27255@order.stressinduktion.org> <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com> <20140410235459.GK27255@order.stressinduktion.org> <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com> <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com> <534753D4.6070600@linux-ipv6.org> <1397186427.16584.86.camel@edumazet-glaptop2.roam.corp.google.com> <1397190216.16584.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37556 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757835AbaDKNWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 09:22:08 -0400
Content-Disposition: inline
In-Reply-To: <1397190216.16584.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 10, 2014 at 09:23:36PM -0700, Eric Dumazet wrote:
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
> ---
> v3: fix title... humpff...

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Eric, the optimization for limiting the mtu in tcp case is still possible.
It is not that people don't care. ;)

Thanks,

  Hannes
