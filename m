From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6 mcast: Do not join device multicast for interface-local multicasts.
Date: Sun, 10 Feb 2013 13:51:19 +0100
Message-ID: <20130210125119.GC18219@order.stressinduktion.org>
References: <51165D66.5090200@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55349 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754599Ab3BJMvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 07:51:20 -0500
Content-Disposition: inline
In-Reply-To: <51165D66.5090200@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 09, 2013 at 11:29:58PM +0900, YOSHIFUJI Hideaki wrote:
> RFC4291 (IPv6 addressing architecture) says that interface-Local scope
> spans only a single interface on a node.  We should not join L2 device
> multicast list for addresses in interface-local (or smaller) scope.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Had this patch in my tree while testing and it is definitely the right thing
to do:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
