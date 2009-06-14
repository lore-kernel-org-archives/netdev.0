From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use a deferred timer in rt_check_expire
Date: Sat, 13 Jun 2009 23:38:50 -0700 (PDT)
Message-ID: <20090613.233850.60730150.davem@davemloft.net>
References: <4A31F13F.9080301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tero.Kristo@nokia.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752072AbZFNGir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 02:38:47 -0400
In-Reply-To: <4A31F13F.9080301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Jun 2009 08:10:07 +0200

> For the sake of power saver lovers, use a deferrable timer to fire rt_check_expire()
> 
> As some big routers cache equilibrium depends on garbage collection done in time,
> we take into account elapsed time between two rt_check_expire() invocations 
> to adjust the amount of slots we have to check.
> 
> Based on an initial idea and patch from Tero Kristo
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Tero Kristo <tero.kristo@nokia.com>

Applied.
