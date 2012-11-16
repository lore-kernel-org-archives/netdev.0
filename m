From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: handle tcp_net_metrics_init() order-5 memory
 allocation failures
Date: Thu, 15 Nov 2012 16:47:39 -0800
Message-ID: <1353026859.10798.12.camel@edumazet-glaptop>
References: <1353022864.10798.6.camel@edumazet-glaptop>
	 <1353023752.24310.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Julien Tinnes <jln@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59768 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083Ab2KPArm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 19:47:42 -0500
Received: by mail-pa0-f46.google.com with SMTP id hz1so1467162pad.19
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 16:47:41 -0800 (PST)
In-Reply-To: <1353023752.24310.1.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 15:55 -0800, Joe Perches wrote:

> maybe readd the warning for OOM reporting here?
> 


Storing tcp metrics is a best effort, this can be silently ignored.

And order-0 are going to work, unless machine is in critical state,
that gives enough room.
