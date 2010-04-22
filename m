From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] dst: rcu check refinement
Date: Thu, 22 Apr 2010 16:07:12 -0700 (PDT)
Message-ID: <20100422.160712.139100575.davem@davemloft.net>
References: <1271971818.7895.6547.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56567
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753768Ab0DVXHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 19:07:07 -0400
In-Reply-To: <1271971818.7895.6547.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Apr 2010 23:30:18 +0200

> __sk_dst_get() might be called from softirq, with socket lock held.
> 
...
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
