From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Fri, 11 Apr 2014 04:57:07 +0200
Message-ID: <20140411025707.GM27255@order.stressinduktion.org>
References: <5345A2B3.7040602@gmail.com> <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com> <20140409223546.GH27255@order.stressinduktion.org> <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com> <20140410235459.GK27255@order.stressinduktion.org> <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com> <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com> <534753D4.6070600@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36488 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064AbaDKC5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 22:57:08 -0400
Content-Disposition: inline
In-Reply-To: <534753D4.6070600@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2014 at 11:30:44AM +0900, YOSHIFUJI Hideaki wrote:
> Eric Dumazet wrote:
> 
> > We must limit the IPv6 MTU to (65535 + 40) bytes in theory.
> > 
> > In practice, its better to align to a multiple of 4 for optimal TCP
> > performance.
> 
> It is a TCP issue.  We should not limit the mtu to 65532+40.
> I am for 65535+40. Otherwise, other protocol such as UDP cannot
> use full mtu as before.

I have not seen problems with max ipv6 mtu limit of 65535+40 and tcp.

I agree this would be a better approach, and maybe & ~3 the mtu/mss
in tcp code? I assume people expect maximum udp packet sizes working
over loopback?

Greetings,

  Hannes
