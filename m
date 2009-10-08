From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add netdev_alloc_skb_ip_align() helper
Date: Wed, 07 Oct 2009 22:40:36 -0700 (PDT)
Message-ID: <20091007.224036.247820677.davem@davemloft.net>
References: <1254969161-3609-1-git-send-email-thomas@wytron.com.tw>
	<4ACD585B.5080106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas@wytron.com.tw, netdev@vger.kernel.org,
	thierry.reding@avionic-design.de, nios2-dev@sopc.et.ntust.edu.tw,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753449AbZJHFkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 01:40:40 -0400
In-Reply-To: <4ACD585B.5080106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Oct 2009 05:11:23 +0200

> David, maybe we should add following helper :
> 
> [PATCH] net: Add netdev_alloc_skb_ip_align() helper
> 
> Instead of hardcoding NET_IP_ALIGN stuff in various network drivers, we can
> add a helper around netdev_alloc_skb()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks ok, but I want to look at how often this exact sequence
would match.  If it applies to a lot of cases, I'll add this
but I know of many exceptions in my head already :-)
