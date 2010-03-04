From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] wireless: convert to use
 netdev_for_each_mc_addr
Date: Thu, 04 Mar 2010 03:38:17 -0800 (PST)
Message-ID: <20100304.033817.217826832.davem@davemloft.net>
References: <20100304.004150.129762672.davem@davemloft.net>
	<20100304.005246.240968829.davem@davemloft.net>
	<20100304092014.GC2721@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jussi.kivilinna@mbnet.fi,
	linux-wireless@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755823Ab0CDLh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 06:37:59 -0500
In-Reply-To: <20100304092014.GC2721@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 4 Mar 2010 10:20:14 +0100

> Slapping myself twice on each cheek.
> 
> Subject: [net-2.6 PATCH] rndis_wlan: correct multicast_list handling V3
> 
> My previous patch (655ffee284dfcf9a24ac0343f3e5ee6db85b85c5) added locking in
> a bad way. Because rndis_set_oid can sleep, there is need to prepare multicast
> addresses into local buffer under netif_addr_lock first, then call
> rndis_set_oid outside. This caused reorganizing of the whole function.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Reported-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Applied.
