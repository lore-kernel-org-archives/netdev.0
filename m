From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] wireless: convert to use
 netdev_for_each_mc_addr
Date: Thu, 04 Mar 2010 00:41:50 -0800 (PST)
Message-ID: <20100304.004150.129762672.davem@davemloft.net>
References: <20100303175229.GB2760@psychotron.redhat.com>
	<20100303200510.17531s9x98zyvwm8@hayate.sektori.org>
	<20100303180956.GC2760@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jussi.kivilinna@mbnet.fi,
	linux-wireless@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36185
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754426Ab0CDIlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:41:31 -0500
In-Reply-To: <20100303180956.GC2760@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 3 Mar 2010 19:09:56 +0100

> Here's corrected patch:
> 
> Subject: [net-2.6 PATCH] rndis_wlan: correct multicast_list handling V2
> 
> My previous patch (655ffee284dfcf9a24ac0343f3e5ee6db85b85c5) added locking in
> a bad way. Because rndis_set_oid can sleep, there is need to prepare multicast
> addresses into local buffer under netif_addr_lock first, then call
> rndis_set_oid outside. This caused reorganizing of the whole function.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Reported-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Applied.
