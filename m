From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] loopback: use u64_stats_sync
 infrastructure
Date: Fri, 25 Jun 2010 21:34:17 -0700 (PDT)
Message-ID: <20100625.213417.149820807.davem@davemloft.net>
References: <1277246651.2591.249.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751049Ab0FZEeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:34:04 -0400
In-Reply-To: <1277246651.2591.249.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Jun 2010 00:44:11 +0200

> Commit 6b10de38f0ef (loopback: Implement 64bit stats on 32bit arches)
> introduced 64bit stats in loopback driver, using a private seqcount and
> private helpers.
> 
> David suggested to introduce a generic infrastructure, added in (net:
> Introduce u64_stats_sync infrastructure)
> 
> This patch reimplements loopback 64bit stats using the u64_stats_sync
> infrastructure.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
