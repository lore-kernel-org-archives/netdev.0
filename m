From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [IPv6] PROBLEM? Network unreachable despite correct route
Date: Wed, 17 Jan 2007 09:14:20 +0100
Message-ID: <20070117081420.GA1613@ff.dom.local>
References: <20070111125343.GB3561@ff.dom.local> <45A636C0.6050507@birkenwald.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:52717 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751797AbXAQIML (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 03:12:11 -0500
To: Bernhard Schmidt <berni@birkenwald.de>
Content-Disposition: inline
In-Reply-To: <45A636C0.6050507@birkenwald.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 11, 2007 at 02:08:16PM +0100, Bernhard Schmidt wrote:
> Jarek Poplawski wrote:
> 
> >>ip -6 route:
> >>2001:4ca0:0:f000::/64 dev eth0  proto kernel  metric 256  expires 
> >>86322sec mtu 1500 advmss 1440 fragtimeout 4294967295
> >>fe80::/64 dev eth0  metric 256  expires 21225804sec mtu 1500 advmss 1440 
> >>fragtimeout 4294967295
> >>ff00::/8 dev eth0  metric 256  expires 21225804sec mtu 1500 advmss 1440 
> >>fragtimeout 4294967295
> >>default via fe80::2d0:4ff:fe12:2400 dev eth0  proto kernel  metric 1024  
> >>expires 1717sec mtu 1500 advmss 1440 fragtimeout 64
> >>unreachable default dev lo  proto none  metric -1  error -101 fragtimeout 
> >>255

I've a look at this once more and have one more doubt:
probably it's some other ip6 trick again, but why this
default router doesn't have "normal" address in the
same segment (2001:4ca0:.../64)? 

Regards,
Jarek P.
