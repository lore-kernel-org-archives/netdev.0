From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: Fix veth_get_stats()
Date: Thu, 19 Nov 2009 12:27:43 -0800 (PST)
Message-ID: <20091119.122743.137434070.davem@davemloft.net>
References: <4B042A53.9010301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51873
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755806AbZKSU10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 15:27:26 -0500
In-Reply-To: <4B042A53.9010301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Nov 2009 18:09:39 +0100

> veth_get_stats() can be called in parallel on several cpus.
> 
> It's better to not reset dev->stats as it could give wrong result on
> one cpu. Use temporary variables, then store the final results.
> 
> Also, we should loop on every possible cpus, not only online cpus,
> or cpu hotplug can suddenly give wrong veth stats.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
