From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Thu, 30 Aug 2007 17:39:12 -0700 (PDT)
Message-ID: <20070830.173912.79067694.davem@davemloft.net>
References: <200708310009.RAA04175@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46863
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750916AbXHaAjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 20:39:13 -0400
In-Reply-To: <200708310009.RAA04175@tardy.cup.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 30 Aug 2007 17:09:04 -0700 (PDT)

> Enable configuration of the minimum TCP Retransmission Timeout via
> a new sysctl "tcp_rto_min" to help those who's networks (eg cellular)
> have quite variable RTTs avoid spurrious RTOs.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> Signed-off-by: Lamont Jones <lamont@hp.com>

Thanks for doing this work Rick.

But as John Heffner and I both mentioned, it's pretty clear we should
do this as a routing metric.  Both for handling realistic scenerios
where the sysctl doesn't work, and to help prevent misuse (example:
someone decides that it would be _totally_ _awesome_ for "Carrier
Grade Linux" to set this to 3 seconds by default in /etc/sysctl.conf
and crap like that).
