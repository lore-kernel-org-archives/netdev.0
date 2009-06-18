From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: correct off-by-one write allocations reports
Date: Wed, 17 Jun 2009 19:05:52 -0700 (PDT)
Message-ID: <20090617.190552.127426863.davem@davemloft.net>
References: <4A37F495.9030101@gmail.com>
	<4A37FC93.7070403@gmail.com>
	<4A389031.1060902@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, mingo@elte.hu,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752615AbZFRCFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:05:49 -0400
In-Reply-To: <4A389031.1060902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Jun 2009 08:41:53 +0200

> [PATCH] net: correct off-by-one write allocations reports
> 
> commit 2b85a34e911bf483c27cfdd124aeb1605145dc80 
> (net: No more expensive sock_hold()/sock_put() on each tx)
> changed initial sk_wmem_alloc value.
> 
> We need to take into account this offset when reporting
> sk_wmem_alloc to user, in PROC_FS files or various
> ioctls (SIOCOUTQ/TIOCOUTQ)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
