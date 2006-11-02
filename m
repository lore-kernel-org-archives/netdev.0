From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/6] IPv6: Do mandatory IPv6 tunnel endpoint checks in
 realtime
Date: Thu, 02 Nov 2006 22:04:23 +0900 (JST)
Message-ID: <20061102.220423.85947582.yoshfuji@linux-ipv6.org>
References: <4549D716.7090600@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:4619 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1752149AbWKBNBf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 08:01:35 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <4549D716.7090600@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4549D716.7090600@tcs.hut.fi> (at Thu, 02 Nov 2006 13:31:34 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> >From e60ed41fb11793d16ffcbfd56b889e0bbf04ea88 Mon Sep 17 00:00:00 2001
> From: Ville Nuorvala <vnuorval@tcs.hut.fi>
> Date: Thu, 2 Nov 2006 12:43:50 +0200
> Subject: [PATCH 2/6] IPv6: Do mandatory IPv6 tunnel endpoint checks in realtime
> 
> Doing the mandatory tunnel endpoint checks when the tunnel is set up
> isn't enough as interfaces can go up or down and addresses can be
> added or deleted after this. The checks need to be done realtime when
> the tunnel is processing a packet.
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

However, this does not seem efficient and we'd probably better to find
better way.

--yoshfuji
