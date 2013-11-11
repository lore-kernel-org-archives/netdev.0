From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: match those routes that have different metirc
Date: Mon, 11 Nov 2013 07:07:53 +0100
Message-ID: <20131111060753.GA27030@order.stressinduktion.org>
References: <52804865.8090206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34595 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3KKGHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 01:07:54 -0500
Content-Disposition: inline
In-Reply-To: <52804865.8090206@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 11:00:53AM +0800, Duan Jiong wrote:
> Now the kernel only match those routes that have the same
> metirc, so if those routes are non-reachable, then the packets
> can't be sent out.
> 
> But according to the rfc 4191 section 3.2, if the best route
> points to a non-reachable route, the next best route should be
> consulted. So the kernel should not only match those routes that
> have minimum metric, and should also match others.

I am not so keen on chaning how metrics get handled. Please note that
metrics are a pure linux-centric concept and are not standardized. I bet
some people depend on how these work and have the same semantic as IPv4
ones because they use the same code in their routing daemon backends.

Also, I think it is better targetted for net-next, which is currently closed.
So we have some time to discuss. ;)

Greetings,

  Hannes
