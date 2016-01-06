From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: move ndo_features_check() close to
 ndo_start_xmit()
Date: Wed, 06 Jan 2016 16:00:47 -0500 (EST)
Message-ID: <20160106.160047.804733684881098004.davem@davemloft.net>
References: <1452092030.8255.178.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbcAFVAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 16:00:49 -0500
In-Reply-To: <1452092030.8255.178.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jan 2016 06:53:50 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> TX fast path uses ndo_start_xmit(), ndo_features_check() and
> ndo_select_queue().
> 
> Move ndo_features_check() close to ndo_start_xmit() to increase
> data locality.
> 
> All "struct net_device_ops" should now be using C99 initializers.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
