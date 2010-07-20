From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] cxgb4vf: Fix off-by-one error checking
 for the end of the mailbox delay array
Date: Tue, 20 Jul 2010 13:23:32 -0700 (PDT)
Message-ID: <20100720.132332.121261970.davem@davemloft.net>
References: <201007200858.52364.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50139
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761536Ab0GTUXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 16:23:15 -0400
In-Reply-To: <201007200858.52364.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Tue, 20 Jul 2010 08:58:52 -0700

>>From 1d32860335fad8c67e23254aec7c30750276f2b4 Mon Sep 17 00:00:00 2001
> From: Casey Leedom <leedom@chelsio.com>
> Date: Mon, 19 Jul 2010 17:51:46 -0700
> Subject: [PATCH net-next 1/3] cxgb4vf: Fix off-by-one error checking for the end of the mailbox delay array
> 
> Fix off-by-one error in checking for the end of the mailbox response delay
> array.  We ended up walking off the end and, if we were unlucky, we'd end up
> pulling in a 0 and never terminate the mailbox response delay loop ...
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied.
