From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Tue, 05 Oct 2010 00:24:50 -0700 (PDT)
Message-ID: <20101005.002450.58425682.davem@davemloft.net>
References: <1285941388.2641.175.camel@edumazet-laptop>
	<20101002093255.GA2049@del.dom.local>
	<1286035915.2582.2472.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34555
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753882Ab0JEHY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 03:24:29 -0400
In-Reply-To: <1286035915.2582.2472.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 02 Oct 2010 18:11:55 +0200

> [PATCH net-next V3] net: dynamic ingress_queue allocation
> 
> ingress being not used very much, and net_device->ingress_queue being
> quite a big object (128 or 256 bytes), use a dynamic allocation if
> needed (tc qdisc add dev eth0 ingress ...)
> 
> dev_ingress_queue(dev) helper should be used only with RTNL taken.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This looks good to me, applied, thanks Eric.
