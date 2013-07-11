From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Thu, 11 Jul 2013 16:46:23 +0200
Message-ID: <20130711144623.GA5707@order.stressinduktion.org>
References: <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com> <20130710212149.GA26122@order.stressinduktion.org> <51DE671F.5050706@6wind.com> <20130711102441.GC5207@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:39381 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932765Ab3GKOqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 10:46:25 -0400
Content-Disposition: inline
In-Reply-To: <20130711102441.GC5207@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 11, 2013 at 12:24:41PM +0200, Hannes Frederic Sowa wrote:
> I fear, I'll need to do a bit more research.

My proposal is to take my patch and check for RTF_ADDRCONF plus RTF_DYNAMIC,
too. The RTF_DYNAMIC check would prevent routes created from icmpv6 redirects
entering an ecmp route set.

Do you agree?

Thanks,

  Hannes
